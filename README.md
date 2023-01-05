# HCP Packer Pipeline Leveraging HCP Vault for Sensitive Variables

This repository documents an example workflow for integrating HCP Vault into a CI/CD pipeline that manages an HCP Packer image. The individual aspects of this approach are well documented in several sources that will be referenced throughout this repository. As opposed to addressing a technical challenge, the goal here is to briefly cover the challenges an organization may face with image, secrets, and pipeline management, then provide an example of how these solutions can come together to address those challenges.

## Current Challenges 

**Image Management**- One of my first roles as a server admin was to build physical servers based on a checklist, then ship those servers out to our remote locations. Later on in my career I began consulting and realized the challenges I ran into in that role, were often experienced by many of my customers. A quick run down of some of those include- 

* Running through a lot of manual steps both in the build and QA of the image
* Inability to track changes or history of various images
* My personal favorite- "Use this image, it was build 5 years ago, not sure what's on it, but it just works" 

Tools like Packer provide a codified method of building images and when that code is stored in a VCS, a lot of the common challenges noted can be addressed. Packer is a powerful tool that makes image deployment significantly easier, but on its own it may not be enough for large scale organizations that are collaborating across teams and multiple clouds with varying images that are constantly being updated. 

**Pipeline Management**- Pipelines can be complex to manage, especially at an Enterprise level. Enterprise organizations often have multiple teams working on different projects and pipelines. Managing access and permissions, as well as coordinating and collaborating across teams can be challenging. These challenges may stem from- 

* Overly complex pipelines
* Lack of communication, documentation, and/or ownership
* Different approaches to deployment 
    
Simplifying access, scope, and establishing a clear framework for the pipeline can help address many of these challenges. Versatile solutions need to be implemented as a part of that framework that can meet the needs of as many teams as possible, while conforming to the governance and compliance standards an enterprise level organization sets. 

**Secrets Management**- Having spoken to customer over the past 3 years about their approach to secrets management I've noticed many developers initially opt for the solution that helps them operate with the most velocity, but as more compliance regulatory demands are put on them a few recurring challenges start to surface. 

* Long-lived credentials are often used and are a security risk because they provide ongoing access to resources for an extended period of time. If an attacker gains access to a long-lived credential, they can use it to continue to access and potentially compromise the associated resources.
* Without the capabilities to enable end-users, securely rotating secrets can also be a challenge. I've seen organizations do this many different ways, including a workflow that has them send credentials over their chat tool to the security team to have them rotate the credentials. 
* Often times when a workflow is up and running and an app is leveraging a certain set of credentials, there is little desire for change. That won't cut it for auditors. They want to know when a secret was instantiated, who has access, when did they access it, what the plan is to rotate it, and more. For many organizations keeping track of all of that is a tall order.

Leveraging tools like Vault can help automate the secrets management processes to help improve efficiency, while ensuring that automation does not compromise security. Vault provides the capabilities and an ability to adhere to a framework set, but it does not guarantee a strong security posture on it's own. Organizations need to continuously work to understand their potential vulnerabilities and address them.

[This learn guide](https://developer.hashicorp.com/packer/tutorials/cloud-production/github-actions) provides a great reference in how to automate Packer in a pipeline and integrate with HCP Packer. This example leverages solutions to address a lot of the challenges mentioned above and works very well for individuals. The below provides a visualization of what that workflow may look like and how the teams would interact together in managing the credentials required for an image pipeline, which is where addressing the remaining challenges around secrets management becomes critical. 

![image](https://user-images.githubusercontent.com/56609570/210869213-d5c66e5e-46df-4b95-a5d6-8337775106e6.png)

Some of the biggest challenges that would need to be addressed with the example workflow above include- 
* Centralizing secrets management
* Removing the need for long lived cloud credentials
* Limiting and tracking secrets management

## Solution

The learn guide referenced above leverages HCP Packer, which provides a registry that allows for the management of images, tracking/identifying parent-child relationships, and also image revocation.  Layering on a centralized secrets management tool, like HCP Vault, would address some of the remaining common challenges noted. An example of what that updated workflow would look like is noted below. 

![image](https://user-images.githubusercontent.com/56609570/210869977-7b9b3587-ef20-4fe8-a9fb-322f2ec694c6.png)

The biggest changes and value with this new workflow are-
* Promoting operational efficiencies by centralizing secrets management. Multiple teams no longer need access to the sensitive variables within the pipeline, they can now manage their secrets directly from Vault and the next time that pipeline is run, it pulls the new secrets. This removes the need of for them to manage a separate secrets repository, then update the pipeline with those variables. 
* Direct integrations with the CI/CD tool to allow for machine authentication, which tracks and securely logs when and how the sensitive variables were accessed. By leveraging an AppRole within Vault, a unique identity can be created for the application that has different permissions than the teams. For example, in the above the github AppRole has access to create Dynamic Azure credentials and view the App and Infrastructure teams KV secrets, while those individual teams only have a access to their credentials. 
* Securely separating out access to sensitive variables among the various teams. The infrastructure team can store image secrets like root credentials and the App team can store Database creds, but the teams would only have visibility/access to their own secrets. This removes concerns that a team may access or change variables they should not have and provides a clear path for them to manage their own secrets.  
* Generating dynamic cloud credentials for a stronger security posture. Cloud credentials often have broad levels of access to the cloud environment, normally including the creation of new resources. In the wrong hands, those credentials can be used to spin up unwanted resources or gain access to information that can be exploited. 
* Managed solution with baked in aspects of HA that remove the need to manually deploy or manage an Enterprise Vault cluster.

## Demo

This repo contains: 
* The scripts to create an HCP Channel iteration based on the iteration id
* The build and deploy GitHub actions workflow
* The packer build file

Prerequisites:
* A [GitHub account](https://github.com/)
* An [HCP account](https://portal.cloud.hashicorp.com/sign-in?utm_source=learn)
* An [HCP Packer Registry](https://developer.hashicorp.com/packer/tutorials/hcp-get-started/hcp-push-image-metadata#create-hcp-packer-registry) and [HCP service principal](https://developer.hashicorp.com/packer/tutorials/hcp-get-started/hcp-push-image-metadata#create-hcp-service-principal-and-set-to-environment-variable)
* An [HCP Vault Cluster](https://developer.hashicorp.com/vault/tutorials/cloud)
* A Microsoft Azure Account

To Do: 
* Provide step-by-step guide to implement pipeline that walks the audience through setting up the custom AppRole and leverages that in the GitHub pipeline.

## Documentation & Related Tutorials
* [Create an HCP Vault Cluster](https://developer.hashicorp.com/vault/tutorials/cloud/get-started-vault)
* [Azure Secrets Engine](https://developer.hashicorp.com/vault/tutorials/secrets-management/azure-secrets)
* [Setup Vault AppRole](https://developer.hashicorp.com/vault/tutorials/auth-methods/approle)
* [Automate Packer with GitHub Actions](https://developer.hashicorp.com/packer/tutorials/cloud-production/github-actions)

