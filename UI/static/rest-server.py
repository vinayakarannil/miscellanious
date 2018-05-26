#!flask/bin/python
################################################################################################################################
#------------------------------------------------------------------------------------------------------------------------------                                                                                                                             
# This file implements the REST layer. It uses flask micro framework for server implementation. Calls from front end reaches 
# here as json and being branched out to each projects. Basic level of validation is also being done in this file. #                                                                                                                                  	       
#-------------------------------------------------------------------------------------------------------------------------------                                                                                                                              
################################################################################################################################
from flask import Flask, jsonify, abort, request, make_response, url_for,redirect, render_template
from flask.ext.httpauth import HTTPBasicAuth
from werkzeug.utils import secure_filename
import os
import sys
import random
import re
from tensorflow.python.platform import gfile
from six import iteritems
sys.path.append('../..')
from dl_transfer_learning_service.trunk.lib.retrain import train_graph
from dl_image_recognition.trunk.lib.predict import inference
import shutil 
import numpy as np
from dl_image_search.trunk.lib.search import recommend
from dl_face_recognition.trunk.lib.src import retrieve
from dl_face_recognition.trunk.lib.src.align import detect_face
from dl_object_detection.trunk.lib.infer_face import run_inference_on_image
from dl_sentiment_analysis.trunk.lib.eval import classify 
sys.path.append('/home/impadmin/object_detection/models/tf-image-segmentation/tf_image_segmentation')
from segment import segment_img
import tarfile
from dl_object_detection.trunk.lib.ssd import detect, detectimg
from datetime import datetime
from scipy import ndimage
from scipy.misc import imsave 
import tensorflow as tf
import pickle
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg'])
from tensorflow.python.platform import gfile
app = Flask(__name__, static_url_path = "")
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
auth = HTTPBasicAuth()
def get_model_filenames(model_dir):
    files = os.listdir(model_dir)
    meta_files = [s for s in files if s.endswith('.meta')]
    if len(meta_files)==0:
        raise ValueError('No meta file found in the model directory (%s)' % model_dir)
    elif len(meta_files)>1:
        raise ValueError('There should not be more than one meta file in the model directory (%s)' % model_dir)
    meta_file = meta_files[0]
    meta_files = [s for s in files if '.ckpt' in s]
    max_step = -1
    for f in files:
        step_str = re.match(r'(^model-[\w\- ]+.ckpt-(\d+))', f)
        if step_str is not None and len(step_str.groups())>=2:
            step = int(step_str.groups()[1])
            if step > max_step:
                max_step = step
                ckpt_file = step_str.groups()[0]
    return meta_file, ckpt_file
#==============================================================================================================================
#                                                                                                                              
#    Loading the extracted feature vectors for image retrieval                                                                 
#                                                                          						        
#                                                                                                                              
#==============================================================================================================================
extracted_features=np.zeros((10000,2048),dtype=np.float32)
#with open('../../dl_image_search/trunk/lib/saved_features_recom.txt') as f:
    		#for i,line in enumerate(f):
        		#extracted_features[i,:]=line.split()
print("loaded extracted_features") 
with open('../../dl_image_search/trunk/lib/extracted_dict.pickle','rb') as f:
            	extracted_dict = pickle.load(f) 
with open('../../dl_image_search/trunk/lib/extracted_dict_boots.pickle','rb') as f:
            	extracted_dict_boots = pickle.load(f) 
with open('../../dl_image_search/trunk/lib/extracted_dict_apparels.pickle','rb') as f:
            	extracted_dict_apparels = pickle.load(f) 
with open('../../dl_image_search/trunk/lib/extracted_dict_sandals.pickle','rb') as f:
            	extracted_dict_sandals = pickle.load(f) 
with open('../../dl_image_search/trunk/lib/extracted_dict_shoes.pickle','rb') as f:
            	extracted_dict_shoes = pickle.load(f) 
with open('../../dl_image_search/trunk/lib/extracted_dict_slippers.pickle','rb') as f:
            	extracted_dict_slippers = pickle.load(f) 
with open('../../dl_face_recognition/trunk/lib/src/extracted_dict_bkp.pickle','rb') as f:
					    	feature_array = pickle.load(f) 

model_exp = '../../dl_face_recognition/trunk/lib/src/ckpt/20170512-110547'
graph_fr = tf.Graph()
sess_fr = tf.Session(graph=graph_fr)
with graph_fr.as_default():
	saverf = tf.train.import_meta_graph(os.path.join(model_exp, 'model-20170512-110547.meta'))
	saverf.restore(sess_fr, os.path.join(model_exp, 'model-20170512-110547.ckpt-250000'))
	pnet, rnet, onet = detect_face.create_mtcnn(sess_fr, None)
#==============================================================================================================================
#                                                                                                                              
#    Error handling routines                                                        					       
#                                                                          						        
#                                                                                                                              
#==============================================================================================================================
@auth.get_password
def get_password(username):
    if username == 'impetus':
        return 'ilabs'
    return None
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
@auth.error_handler
def unauthorized():
    return make_response(jsonify( { 'error': 'Unauthorized access' } ), 403)
    # return 403 instead of 401 to prevent browsers from displaying the default auth dialog
    
@app.errorhandler(400)
def not_found(error):
    return make_response(jsonify( { 'error': 'Bad request' } ), 400)
 
@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify( { 'error': 'Not found' } ), 404)


#==============================================================================================================================
#                                                                                                                              
#    This function is used to test the trained model at the spot.                                                              
#    used in: dl_transfer_learning_service                                                                                      
#                                                                                                                              
#==============================================================================================================================
@app.route('/fileUploadtest', methods=['GET', 'POST'])
#@auth.login_required
def upload_file_test():
    
    if request.method == 'POST' or request.method == 'GET':
        # check if the post request has the file part
        if 'file' not in request.files:
            print('No file part')
            return redirect(request.url)
        file = request.files['file']
        # if user does not select file, browser also
        # submit a empty part without filename
        if file.filename == '':
            print('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            inputloc = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            outputloc = 'static/Downloads'
            label1, score, accuracy = inference(inputloc,outputloc)
            os.remove(inputloc)
            label = label1.replace("\n", "")
	    if(label == 'oots'):
		label = 'boots'
            data = {
			'label':label.upper(),
                        'score':score	
		    }
            return jsonify(data)
           
#==============================================================================================================================
#                                                                                                                              
#    This function is used to recognize uploaded images.                                                                       
#    used in: dl_image_recognition                                                                                              
#                                                                                                                              
#==============================================================================================================================
@app.route('/fileUpload', methods=['GET', 'POST'])
#@auth.login_required
def upload_file():
    print("file upload")
    result = 'static/uploads/test'
    if not gfile.Exists(result):
          os.mkdir(result)
    shutil.rmtree(result)
    if request.method == 'POST' or request.method == 'GET':
        # check if the post request has the file part
        if 'file' not in request.files:
            print('No file part')
            return redirect(request.url)
        file = request.files['file']
        # if user does not select file, browser also
        # submit a empty part without filename
        if file.filename == '':
            print('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            inputloc = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            outputloc = 'out/specific'
            label1, score, accuracy = inference(inputloc,outputloc)
            image = ndimage.imread(inputloc)
            os.mkdir('static/uploads/test')           
            timestr = datetime.now().strftime("%Y%m%d%H%M%S")
            name= timestr+"."+"test"
            print(name)
            name = 'static/uploads/test/'+name+'.jpg'
            imsave(name, image)
            os.remove(inputloc)
            label = label1.replace("\n", "")
	    if(label == 'oots'):
		label = 'boots'
            print("label:",label)
	    print("score:", score)

            image_path = "/uploads/test"
            image_list =[os.path.join(image_path,file) for file in os.listdir(result)
                              if not file.startswith('.')]
            print("image name",image_list)
            if(accuracy < 0.3):
                   label = 'Unknown Class'
                   score = '-'
	    data = {
			'label':label,
                        'score':score,
                        'image0':image_list[0]	
		    }
            return jsonify(data)

#==============================================================================================================================
#                                                                                                                              
#  This function is used to extract the uploaded dataset and train an inception model.                                         
#  used in: dl_transfer_learning_service                                                                                        
#                                                                                                                              
#==============================================================================================================================
@app.route('/dataUpload', methods=['GET', 'POST'])
#@auth.login_required
def upload_folder():
    print("data upload")
    outputloc = 'static/Downloads'
    #if not gfile.Exists(outputloc):
          #os.mkdir(outputloc)
    #shutil.rmtree(outputloc)
    #os.mkdir(outputloc)
    if request.method == 'POST' or request.method == 'GET':
        # check if the post request has the file part
        if 'file' not in request.files:
            print('No file part')
            return redirect(request.url)
        file = request.files['file']
        # if user does not select file, browser also
        # submit a empty part without filename
        if file.filename == '':
            print('No selected file')
            return redirect(request.url)
        else:# file and allowed_file(file.filename):
            zip_filename = secure_filename(file.filename)
            filename =zip_filename.split('.')[0]
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], zip_filename))
            
            filename2 = os.path.join(app.config['UPLOAD_FOLDER'], zip_filename)
            tarfile.open(filename2, 'r:gz').extractall(app.config['UPLOAD_FOLDER'])
            os.remove(filename2)
            inputloc = os.path.join(app.config['UPLOAD_FOLDER'], filename)
	    shutil.make_archive('static/model', 'zip', outputloc)
            status, accuracy = train_graph(inputloc,outputloc)
	    data = {
			'status':status,
                        'accuracy':accuracy	
		    }	

            return jsonify(data)

#==============================================================================================================================
#                                                                                                                              
#  This function is used to do the image search/image retrieval                                                                
#  used in: dl_image_search                                                                                                     
#                                                                                                                              
#==============================================================================================================================
@app.route('/imgUpload', methods=['GET', 'POST'])
#@auth.login_required
def upload_img():
    print("image upload")
    result = 'static/result'
    if not gfile.Exists(result):
          os.mkdir(result)
    shutil.rmtree(result)
 
    if request.method == 'POST' or request.method == 'GET':
        print(request.method)
        # check if the post request has the file part
        if 'file' not in request.files:
           
            print('No file part')
            return redirect(request.url)
        
        file = request.files['file']
        print(file.filename)
        # if user does not select file, browser also
        # submit a empty part without filename
        if file.filename == '':
           
            print('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
         
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            inputloc = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            #outputloc = '/home/vinayak/todo-api/out'
            outputloc = 'out/specific'
            
            label1, score, accuracy = inference(inputloc,outputloc)
            
            label = label1.replace("\n", "")
	    if(label == 'oots'):
		label = 'boots'
            print("detected:", label)
            if(label == 'boots'):
		result_list = recommend(inputloc, extracted_dict_boots)
            elif(label == 'sandals'):
		result_list = recommend(inputloc, extracted_dict_sandals)
            elif(label == 'slippers'):
		result_list = recommend(inputloc, extracted_dict_slippers)
            elif(label == 'shoes'):
		result_list = recommend(inputloc, extracted_dict_shoes)
            elif(label == 'apparel'):
                segment_img(inputloc)
            	print("done segmentation")
            	os.remove(inputloc)
            	inputloc = os.path.join(app.config['UPLOAD_FOLDER'], "segmented.jpg")
		result_list = recommend(inputloc, extracted_dict_apparels)
            else:
                result_list = recommend(inputloc, extracted_dict)
            #result_list = recommend(inputloc, extracted_dict)
            #os.remove(inputloc)
            #label = label1.replace("\n", "")
            #image_path = "/result"
            #image_list =[os.path.join(image_path,file) for file in os.listdir(result)
                              #if not file.startswith('.')]
            listlen = len(result_list)
            if listlen == 0:
		print("no match found")
            images = {}
            for i in range(listlen):
		images["'"+'image'+str(i)+"'"] = "/"+result_list[i]
            '''images = {
			'image0':"'"+result_list[0]+"'",
                        'image1':result_list[1],	
			'image2':result_list[2],	
			'image3':result_list[3],	
			'image4':result_list[4],	
			'image5':result_list[5],	
			'image6':result_list[6],	
			'image7':result_list[7],	
			'image8':result_list[8]
		      }	'''			
   			
                     
            for i in result_list:
       		print(i)
            return jsonify(images)


#==============================================================================================================================
#                                                                                                                              
#  This function is used to do the image search/image retrieval for files from server itself      #                                                             
#  used in: dl_image_search                                                                                                     
#                                                                                                                              
#==============================================================================================================================
@app.route('/imgsearchserver', methods=['GET', 'POST'])
#@auth.login_required
def upload_img_serv():
    print("imgsearchserver")
    #result = 'static/result'
    #if not gfile.Exists(result):
          #os.mkdir(result)
    #shutil.rmtree(result)
 
    if request.method == 'POST' or request.method == 'GET':
        print(request.method)
        # check if the post request has the file part
        
        
        url = request.json.get("url")
        print(url)
        # if user does not select file, browser also
        # submit a empty part without filename
        
        
         
        
      
      #outputloc = '/home/vinayak/todo-api/out'
        outputloc = 'out/specific'
        label1, score, accuracy = inference(url,outputloc)
        label = label1.replace("\n", "")
	if(label == 'oots'):
		label = 'boots'
        print("detected:", label)
        if(label == 'boots'):
		result_list = recommend(url, extracted_dict_boots)
        elif(label == 'sandals'):
		result_list = recommend(url, extracted_dict_sandals)
        elif(label == 'slippers'):
		result_list = recommend(url, extracted_dict_slippers)
        elif(label == 'shoes'):
		result_list = recommend(url, extracted_dict_shoes)
        elif(label == 'apparel'):
		result_list = recommend(url, extracted_dict_apparels)
        else:
                result_list = recommend(url, extracted_dict)
            
            #label = label1.replace("\n", "")
            #image_path = "/result"
            #image_list =[os.path.join(image_path,file) for file in os.listdir(result)
                              #if not file.startswith('.')]
        listlen = len(result_list)
        if listlen == 0:
		print("no match found")
        images = {}
        for i in range(listlen):
		images["'"+'image'+str(i)+"'"] = "/"+result_list[i]
        '''images = {
			'image0':"'"+result_list[0]+"'",
                        'image1':result_list[1],	
			'image2':result_list[2],	
			'image3':result_list[3],	
			'image4':result_list[4],	
			'image5':result_list[5],	
			'image6':result_list[6],	
			'image7':result_list[7],	
			'image8':result_list[8]
		      }	'''			
   			
                     
        for i in result_list:
       		print(i)
        return jsonify(images)

#==============================================================================================================================
#                                                                                                                              
#  This function is used to do the sentiment analysis                                                                          
#  used in: dl_sentiment_analysis                                                                                               
#                                                                                                                              
#==============================================================================================================================
@app.route('/sentenceUpload', methods=['GET', 'POST'])
#@auth.login_required
def upload_sentence():

    sentence = request.json.get("sentence")
    print(sentence)
    sentiment = classify(sentence.lower())
    response ={
    'status':sentiment
	}
    #sentiment = classify(sentence)
    return jsonify(response)

#==============================================================================================================================
#                                                                                                                              
#  This function is used to do the detection from video camera                                                                 
#  used in: dl_object_detection                                                                                                 
#                                                                                                                              
#==============================================================================================================================
@app.route('/objectDetectLive', methods=['GET', 'POST'])
#@auth.login_required
def obj_det():
    print("video camera")
    detect()

#==============================================================================================================================
#                                                                                                                              
#  This function is used to do the face recognition from video camera                                                          
#  used in: dl_object_detection                                                                                                 
#                                                                                                                              
#==============================================================================================================================
@app.route('/facerecognitionLive', methods=['GET', 'POST'])
#@auth.login_required
def face_det():
    
    retrieve.recognize_face(sess_fr,pnet, rnet, onet,feature_array)

#==============================================================================================================================
#                                                                                                                              
#  This function is used to do the detection from uploaded images                                                              
#  used in: dl_object_detection                                                                                                 
#                                                                                                                              
#==============================================================================================================================
@app.route('/objectDetectImage', methods=['GET', 'POST']) 
#@auth.login_required
def obj_det_img():
  
    print("file upload")
    voc_classes = ['background','aeroplane', 'bicycle', 'bird', 'boat', 'bottle', 'bus', 'car', 'cat', 'chair', 'cow', 'diningtable', 'dog', 'horse', 'motorbike', 'person', 'pottedplant', 'sheep', 'sofa', 'train', 'tvmonitor']
    result1 = 'static/uploads/test'
    result2 = 'static/uploads/test_det'
    #if not gfile.Exists(result):
          #os.mkdir(result)
    if gfile.Exists(result1):
         shutil.rmtree(result1)
    if gfile.Exists(result2):
         shutil.rmtree(result2)
    if request.method == 'POST' or request.method == 'GET':
        # check if the post request has the file part
        if 'file' not in request.files:
            print('No file part')
            return redirect(request.url)
        file = request.files['file']
        # if user does not select file, browser also
        # submit a empty part without filename
        if file.filename == '':
            print('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            inputloc = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            outputimage = 'static/det_results/testplot.jpg'
            #label1, score, accuracy = predict.inference(inputloc,outputloc)
            objects = detectimg(inputloc)
            final_objs = []

            for i in objects:
                  obj = voc_classes[i]                 
                  final_objs.append(obj)
            print("final objects",final_objs)
            image1 = ndimage.imread(inputloc)
            image2 = ndimage.imread(outputimage)
            os.mkdir(result1)  
            os.mkdir(result2)          
            timestr = datetime.now().strftime("%Y%m%d%H%M%S")
            name1= timestr+"."+"test"
            name2= timestr+"."+"test_det"
            #print(name)
            name3 = 'static/uploads/test/'+name1+'.jpg'
            name4 = 'static/uploads/test_det/'+name2+'.jpg'
            imsave(name3, image1)
            imsave(name4, image2)
            os.remove(inputloc)
            #label = label1.replace("\n", "")
	    #if(label == 'oots'):
		#label = 'boots'
            #print("label:",label)
	    

            image_path1 = "/uploads/test"
            image_list1 =[os.path.join(image_path1,file) for file in os.listdir(result1)
                              if not file.startswith('.')]
            image_path2 = "/uploads/test_det"
            image_list2 =[os.path.join(image_path2,file) for file in os.listdir(result2)
                              if not file.startswith('.')]
            print("image name",image_list1)
            print("image name",image_list2)
            #if(accuracy < 0.3):
                   #label = 'Unknown Class'
                   #score = '-'
            data = {
			
                        'image0':image_list1[0],
                        'image1':image_list2[0],
                        'objects':final_objs	
		    }
            return jsonify(data)

#==============================================================================================================================
#                                                                                                                              
#  This function is used to do the detection from uploaded images                                                              
#  used in: dl_image_segmentation                                                                                                
#                                                                                                                              
#==============================================================================================================================
@app.route('/SegmentImage', methods=['GET', 'POST']) 
#@auth.login_required
def segment_image():
  
    print("file upload for image segmentation")

    #if not gfile.Exists(result):
          #os.mkdir(result)
    result1 = 'static/uploads/test'
    result2 = 'static/uploads/test_det'
    #if not gfile.Exists(result):
          #os.mkdir(result)
    if gfile.Exists(result1):
         shutil.rmtree(result1)
    if gfile.Exists(result2):
         shutil.rmtree(result2)
    if request.method == 'POST' or request.method == 'GET':
        # check if the post request has the file part
        if 'file' not in request.files:
            print('No file part')
            return redirect(request.url)
        file = request.files['file']
        # if user does not select file, browser also
        # submit a empty part without filename
        if file.filename == '':
            print('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            inputloc = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            
            #label1, score, accuracy = predict.inference(inputloc,outputloc)
            segment_img(inputloc)
            outputimage = os.path.join(app.config['UPLOAD_FOLDER'], "segmented.jpg")

           
            image1 = ndimage.imread(inputloc)
            image2 = ndimage.imread(outputimage)
            os.mkdir(result1)  
            os.mkdir(result2)          
            timestr = datetime.now().strftime("%Y%m%d%H%M%S")
            name1= timestr+"."+"test"
            name2= timestr+"."+"test_det"
            #print(name)
            name3 = 'static/uploads/test/'+name1+'.jpg'
            name4 = 'static/uploads/test_det/'+name2+'.jpg'
            imsave(name3, image1)
            imsave(name4, image2)
            #os.remove(inputloc)
           

            image_path1 = "/uploads/test"
            image_list1 =[os.path.join(image_path1,file) for file in os.listdir(result1)
                              if not file.startswith('.')]
            image_path2 = "/uploads/test_det"
            image_list2 =[os.path.join(image_path2,file) for file in os.listdir(result2)
                              if not file.startswith('.')]
            print("image name",image_list1)
            print("image name",image_list2)
            #if(accuracy < 0.3):
                   #label = 'Unknown Class'
                   #score = '-'
            data = {
			
                        'image0':image_list1[0],
                        'image1':image_list2[0]
		    }
            return jsonify(data)

#==============================================================================================================================
#                                                                                                                              
#                                           Main function                                                        	            #						     									       
#  				                                                                                                
#==============================================================================================================================
@app.route("/")
def main():
    
    return render_template("main.html")   
if __name__ == '__main__':
    app.run(debug = True, host= '0.0.0.0')
