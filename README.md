# HCP Packer Pipeline Leveraging HCP Vault for Sensitive Variables

This repository documents an example workflow for integrating HCP Vault into a CI/CD pipeline that manages an HCP Packer image. The individual aspects of this approach are well documented in several sources that will be referenced throughout this repository. The goal here is to briefly cover the challenges an organization may face with image, secrets, and pipeline management, then provide an example of how these solutions can come together to address those challenges.

## Current Challenges 

**Image Management**- One of my first roles as a server admin was to build physical servers based on a checklist, then ship those servers out to our remote locations. Later on in my career I began consulting and realized the challenges I ran into in that role, were often experienced by many of my customers. A quick run down of some of those include- 

* Running through a lot of manual steps both in the build and QA of the image
* Inability to track changes or history of various images
* My personal favorite- "Use this image, it was build 5 years ago, not sure what's on it, but it just works" 

Tools like Packer provide a codified method of building images and when that code is stored in a VCS, a lot of the common challenges noted can be addressed. Packer is a powerful tool that makes image deployment significantly easier, but on its own it may not be enough for large scale organizations that are collaborating across teams and multiple clouds with varying images that are constantly being updated. 

**Pipeline Management**- Pipelines can be complex to manage, especially at an Enterprise level. Enterprise organizations often have multiple teams working on different projects and pipelines. Managing access and permissions, as well as coordinating and collaborating across teams can be challenging. These challenges may stem from- 

*Overly complex pipelines
*Lack of communication, documentation, and/or ownership
*Different approaches to deployment 
    
Simplifying access, scope, and establishing a clear framework for the pipeline can help address many of these challenges. Versatile solutions need to be implemented as a part of that framework that can meet the needs of as many teams as possible, while conforming to the governance and compliance standards an enterprise level organization sets. 

**Secrets Management**- Having spoken to customer over the past 3 years about their approach to secrets management I've noticed many developers initially opt for the solution that helps them operate with the most velocity, but as more compliance regulatory demands are put on them a few recurring challenges start to surface. 

* Long-lived credentials are often used and are a security risk because they provide ongoing access to resources for an extended period of time. If an attacker gains access to a long-lived credential, they can use it to continue to access and potentially compromise the associated resources.
* Without the capabilities to enable end-users, securely rotating secrets can also be a challenge. I've seen organizations do this many different ways, including a workflow that has them send credentials over their chat tool to the security team to have them rotate the credentials. 
* Often times when a workflow is up and running and an app is leveraging a certain set of credentials, there is little desire for change. That won't cut it for auditors. They want to know when a secret was instantiated, who has access, when did they access it, what the plan is to rotate it, and more. For many organizations keeping track of all of that is a tall order.

Leveraging tools like Vault can help automate the secrets management processes to help improve efficiency, while ensuring that automation does not compromise security. Vault provides the capabilities and an ability to adhere to a framework set, but it does not guarantee a strong security posture on it's own. Organizations need to continuously work to understand their potential vulnerabilities and address them.

This learn guide provides a great reference in how to automate Packer in a pipeline and integrate with HCP Packer. This example leverages solutions to address a lot of the challenges mentioned above and works very well for individuals. The below provides a visualization of what that workflow may look like and how the teams would interact together in managing the credentials required for an image pipeline, which is where addressing the remaining challenges around secrets management becomes critical. 

![image](https://user-images.githubusercontent.com/56609570/210868694-ebba1e15-d16d-4a67-8f6d-244ee3eb4a5f.png)

Some of the biggest challenges that would need to be addressed with the example workflow above include- 
* Centralizing secrets management
* Removing the need for long lived cloud credentials
* Limiting and tracking secrets management
