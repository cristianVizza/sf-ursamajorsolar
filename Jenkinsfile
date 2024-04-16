#!groovy
import groovy.json.JsonSlurperClassic
node {

    def BUILD_NUMBER=env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR="tests/${BUILD_NUMBER}"
    def SFDC_USERNAME

    def HUB_ORG=env.HUB_ORG_DH
    def SFDC_HOST = env.SFDC_HOST_DH
    def JWT_KEY_CRED_ID = env.JWT_CRED_ID_DH
    def CONNECTED_APP_CONSUMER_KEY=env.CONNECTED_APP_CONSUMER_KEY_DH
    def SF_LOG_LEVEL = env.SF_LOG_LEVEL_DH

    println 'KEY IS' 
    println JWT_KEY_CRED_ID
    println HUB_ORG
    println SFDC_HOST
    println CONNECTED_APP_CONSUMER_KEY
    println SF_LOG_LEVEL_DH
	
    def toolbelt = tool 'toolbelt'

    stage('checkout source') {
        // when running in multi-branch job, one must issue this command
        checkout scm
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
        stage('Deploye Code') {
            if (isUnix()) {
		println 'isUnix authentication'
                rc = sh returnStatus: true, script: "${toolbelt} auth:jwt:grant --client-id ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwt-key-file ${jwt_key_file} --set-default-dev-hub --instance-url ${SFDC_HOST}"
            }else{
		    println 'Other case authetication'
		    //bat "${toolbelt} plugins:install salesforcedx@49.5.0"
		    bat "${toolbelt} update"
		    //bat "${toolbelt} auth:logout -u ${HUB_ORG} -p" 
		    //rc = bat returnStatus: true, script: "${toolbelt} auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwtkeyfile ${jwt_key_file} --loglevel DEBUG --setdefaultdevhubusername --instanceurl ${SFDC_HOST}"
		    //--setdefaultdevhubusername    --set-default-dev-hub
                 rc = bat returnStatus: true, script: "${toolbelt} auth:jwt:grant --client-id ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwt-key-file ${jwt_key_file} --loglevel DEBUG --set-default-dev-hub --instance-url ${SFDC_HOST}"
            }
		
            if (rc != 0) { 
		    println 'inside rc 0'
		    error 'hub org authorization failed' 
	    }
	    else{
			println 'rc not 0'
	    }
	
	     println rc
		
	     // need to pull out assigned username
	     if (isUnix()) {
		     	println 'isUnix deploy'
			//rmsg = sh returnStdout: true, script: "${toolbelt} force:mdapi:deploy -d manifest/. -u ${HUB_ORG}"
			//rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy -x manifest/package.xml -u ${HUB_ORG}"
			rmsg = sh returnStdout: true, script: "${toolbelt} project deploy start -x manifest/package.xml -u ${HUB_ORG}"
	     }else{
		     	println 'else deploy'
			rmsg = bat returnStdout: true, script: "${toolbelt} project deploy start -x manifest/package.xml -u ${HUB_ORG}"
			//rmsg = bat returnStdout: true, script: "${toolbelt} force:source:deploy -x manifest/package.xml -u ${HUB_ORG}"
		        //rmsg = bat returnStdout: true, script: "${toolbelt} force:mdapi:deploy -d manifest/. -u ${HUB_ORG}"
	    }
			  
            printf rmsg
            println('Hello from a Job DSL script!')
            println(rmsg)
        }
    }
}
