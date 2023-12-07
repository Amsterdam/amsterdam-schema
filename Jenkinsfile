#!groovy

def tryStep(String message, Closure block, Closure tearDown = null) {
    try {
        block()
    }
    catch (Throwable t) {
        slackSend message: "${env.JOB_NAME}: ${message} failure ${env.BUILD_URL}", channel: '#ci-channel', color: 'danger'
        throw t
    }
    finally {
        if (tearDown) {
            tearDown()
        }
    }
}

node {
    stage("Checkout") {
        checkout scm
    }

    stage("Build API image") {
        tryStep "build", {
            docker.withRegistry("${DOCKER_REGISTRY_HOST}",'docker_registry_auth') {
            def image = docker.build("datapunt/dataservices/publish-static:${env.BUILD_NUMBER}", ".")
            image.push()
            }
        }
    }
}


node {
    stage("Push ACC image") {
        tryStep "image tagging", {
            docker.withRegistry("${DOCKER_REGISTRY_HOST}",'docker_registry_auth') {
            def image = docker.image("datapunt/dataservices/publish-static:${env.BUILD_NUMBER}")
            image.pull()
            image.push("acceptance")
            }
        }
    }

    stage("Deploy to ACC") {
        tryStep "deployment", {
            build job: 'Subtask_Openstack_Playbook',
                    parameters: [
                            [$class: 'StringParameterValue', name: 'INVENTORY', value: 'acceptance'],
                            [$class: 'StringParameterValue', name: 'PLAYBOOK', value: 'publish-dataservices-static-schemas.yml'],
                    ]
       }
   }
}

stage('Waiting for approval') {
    slackSend channel: '#ci-channel', color: 'warning', message: 'Amsterdam Schema is waiting for Production Release - Please confirm.'
    input "Deploy to Production?"
}

node {
    stage("Push PROD image") {
        tryStep "image tagging", {
            docker.withRegistry("${DOCKER_REGISTRY_HOST}",'docker_registry_auth') {
            def image = docker.image("datapunt/dataservices/publish-static:${env.BUILD_NUMBER}")
            image.pull()
            image.push("production")
            }
        }
    }

    stage("Deploy to PROD") {
        tryStep "deployment", {
            build job: 'Subtask_Openstack_Playbook',
                    parameters: [
                            [$class: 'StringParameterValue', name: 'INVENTORY', value: 'production'],
                            [$class: 'StringParameterValue', name: 'PLAYBOOK', value: 'publish-dataservices-static-schemas.yml'],
                    ]
        }    }

}
