# HCP Packer Pipeline Leveraging HCP Vault for Sensitive Variables

This repository documents an example workflow for integrating HCP Vault into a CI/CD pipeline that manages an HCP Packer image. The individual aspects of this approach are well documented in several sources that will be referenced throughout this repository. As opposed to addressing a technical challenge, the goal here is to briefly cover the challenges an organization may face with image, secrets, and pipeline management, then provide an example of how those challenges can be addressed.

## Current Challenges 

**Image Management**- One of my first roles as a server admin was to build physical servers based on a checklist, then ship those servers out to our remote locations. Later in my career, I began consulting and realized the challenges I ran into in my previous role were often experienced by many of my customers. A quick run-down of some of those include- 

* Running through a lot of manual steps both in the build and QA of the image
* Inability to track changes or history of various images
* My personal favorite- "Use this image, it was built 5 years ago, not sure what's on it, but it just works" 

Tools like Packer provide a codified method of building images and when that code is stored in a VCS, a lot of the common challenges noted can be addressed. Packer is a powerful tool that makes image deployment significantly easier, but on its own it may not be enough for large scale organizations that are collaborating across teams and multiple clouds with varying images that are constantly being updated. 

**Pipeline Management**- Pipelines can be complex to manage, especially at an Enterprise level. Enterprise organizations often have multiple teams working on different projects and pipelines. Managing access and permissions, as well as coordinating and collaborating across teams can be challenging. These challenges may stem from- 

* Overly complex pipelines
* Lack of communication, documentation, and/or ownership
* Different approaches to deployment 
    
Simplifying access and scope as well as establishing a clear framework for the pipeline can help address many of these challenges. Versatile solutions need to be implemented as a part of that framework that can meet the needs of as many teams as possible, while  also conforming to the governance and compliance standards set by an enterprise level organization. 

**Secrets Management**- Having spoken to customers over the past 3 years about their approach to secrets management, I've noticed many developers initially opt for the solution that helps them operate with the most velocity. However, as more compliance and regulatory demands are put on them, a few recurring challenges start to surface such as-

* Long-lived credentials are often used and are a security risk because they provide ongoing access to resources for an extended period of time. If an attacker gains access to a long-lived credential, they can use it to continue to access, manipulate, and compromise the associated resources. 
* Without the capabilities to enable end-users, securely rotating secrets can also be a challenge. I've seen organizations do this many different ways that are not ideal, including a workflow that has them send credentials over their chat tool to the security team to have them rotate the credentials. 
* Often when a pipeline is up and running and an app is leveraging a certain set of credentials, there is little desire for change. That won't cut it for auditors. They want to know when a secret was instantiated, who has access, when did they access it, what the plan is to rotate it, and more. For many organizations keeping track of all of that information is a tall order.

Leveraging tools like Vault can help automate the secrets management processes to help improve efficiency, while ensuring that automation does not compromise security. Vault provides the capabilities and an ability to adhere to a framework set, but it does not guarantee a strong security posture on its own. Organizations need to continuously work to understand their potential vulnerabilities and address them.

[This learn guide](https://developer.hashicorp.com/packer/tutorials/cloud-production/github-actions) provides a great reference in how to automate Packer in a pipeline and integrate with HCP Packer. This example leverages solutions to address a lot of the challenges mentioned above and works well for individuals. The below provides a visualization of what that workflow may look like and how the teams would interact together in managing the credentials required for an image pipeline, which is where addressing the remaining challenges around secrets management becomes critical. 

![image](https://user-images.githubusercontent.com/56609570/210869213-d5c66e5e-46df-4b95-a5d6-8337775106e6.png)

Some of the biggest challenges that would need to be addressed with the example workflow above include- 
* Centralizing secrets management
* Removing the need for long lived cloud credentials
* Limiting and tracking secrets management

## Solution

The learn guide referenced above leverages HCP Packer, which provides a registry that allows for the management of images, tracking/identifying parent-child relationships, and also image revocation.  Layering on a centralized secrets management tool, such as HCP Vault, would address some of the remaining common challenges noted. An example of what that updated workflow would look like is noted below. 

![image](https://user-images.githubusercontent.com/56609570/210869977-7b9b3587-ef20-4fe8-a9fb-322f2ec694c6.png)

The biggest changes and value with this new workflow are-
* **Promoting operational efficiencies by centralizing secrets management.** Multiple teams no longer need access to the sensitive variables within the pipeline, they can now manage their secrets directly from Vault and the next time that pipeline is run, it pulls the new secrets. This removes the need for them to manage a separate secrets repository, then update the pipeline with those variables. 
* **Integrations with the CI/CD tool to allow for machine authentication**, which tracks and securely logs when and how the sensitive variables were accessed. By leveraging an AppRole within Vault, a unique identity can be created for the application that has different permissions than the teams. For example, in the above the github AppRole has access to create Dynamic Azure credentials and view the App and Infrastructure teams KV secrets, while those individual teams only have access to their credentials. 
* **Securely separating out access to sensitive variables among the various teams.** Ideally all credentials are dynamic, but there is a need at times for teams to have static credentials and this model securely facilitates that. The Infrastructure team can store image secrets like root credentials and the App team can store Database credentials, but the teams would only have visibility/access to their own secrets. This would remove concerns that a team may access or change variables they should not have and provides a clear path for them to manage their own secrets.   
* **Generating dynamic cloud credentials for a stronger security posture.** Cloud credentials often have broad levels of access to the cloud environment, normally including the creation of new resources. In the wrong hands, those credentials can be used to spin up unwanted resources or gain access to information that can be exploited. 
* **Managed solution with baked in aspects of HA** that remove the need to manually deploy or manage an Enterprise Vault cluster.

## Demo

This repo contains: 
* The scripts to create an HCP Channel iteration based on the iteration id
* The "build-and-deploy" GitHub Actions workflow yaml file
* Examples of the GitHub Actions successfully completing
* The packer build file

Prerequisites:
* A [GitHub account](https://github.com/)
* An [HCP account](https://portal.cloud.hashicorp.com/sign-in?utm_source=learn)
* An [HCP Packer Registry](https://developer.hashicorp.com/packer/tutorials/hcp-get-started/hcp-push-image-metadata#create-hcp-packer-registry) and [HCP service principal](https://developer.hashicorp.com/packer/tutorials/hcp-get-started/hcp-push-image-metadata#create-hcp-service-principal-and-set-to-environment-variable)
* An [HCP Vault Cluster](https://developer.hashicorp.com/vault/tutorials/cloud)
* A Microsoft Azure Account

Setup:
1. Configure the Auth Methods in the HCP Vault cluster-
 * AppRole - For the GitHub Pipeline to authenticate to Vault
 * Method used for user authentication, for this demo I used "Username & Password”, but most Enterprise organizations would integrate with an identity provider such as Okta. 
2. Configure the Secrets Engines in the HCP Vault cluster-
* Key/Value - For any static credentials that may be needed. To update the HCP Packer registry variables like the HCP Project ID, Organization ID, Client ID, and Secret ID will need to be included.
* Azure – This will dynamically generate Azure credentials that are valid based on a lease duration that is set. 
3. Configure 3 policies in the HCP Vault cluster-
* Policy for an App team that can have Read/Write access to their KV secrets. This will include their user group and the KV paths they may need access to (i.e. image credentials, HCP service principal, etc). 
* Similar to the App team policy, a separate policy for an Infrastructure team to access any KV secrets they may have (i.e. database credentials, API tokens, etc).
* An AppRole that has read capabilities to the paths for the Azure credentials and the KV paths for both teams. 
4. Enter the AppRole Role ID and Secret ID as sensitive variables in the GitHub repository. 
5. Copy the contents of this repository and modify as needed. 

Example: 

Under the secrets of this repository the only variables that are stored are the AppRole Role ID and Secret ID-
![image](https://user-images.githubusercontent.com/56609570/211422776-90c0bf96-7475-451f-867a-b94e3b3b90f3.png)

The remaining sensitive variables needed are pulled from Vault-
![image](https://user-images.githubusercontent.com/56609570/211422797-8bdc0a86-d4d3-4efd-a433-99d385b8bc2e.png)

This simplifies the pipleines operations leveraging a single source to store and manage secrets. 

To Do: 
* Provide step-by-step guide to implement pipeline that walks the audience through setting up the custom AppRole and leverages that in the GitHub pipeline.
* Update to include the HCP Packer "latest" release channel

## Documentation & Related Tutorials
* [Create an HCP Vault Cluster](https://developer.hashicorp.com/vault/tutorials/cloud/get-started-vault)
* [Azure Secrets Engine](https://developer.hashicorp.com/vault/tutorials/secrets-management/azure-secrets)
* [Setup Vault AppRole](https://developer.hashicorp.com/vault/tutorials/auth-methods/approle)
* [Automate Packer with GitHub Actions](https://developer.hashicorp.com/packer/tutorials/cloud-production/github-actions)
* [Vault GitHub Action](https://github.com/hashicorp/vault-action)

