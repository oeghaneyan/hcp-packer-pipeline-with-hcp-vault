# HCP Packer Pipeline Leveraging HCP Vault for Sensitive Variables

This repository documents an example workflow for integrating HCP Vault into a CI/CD pipeline that manages an HCP Packer image. The individual aspects of this approach are well documented in several sources that will be referenced throughout this repository. The goal here is to briefly cover the challenges an organization may face with image, secrets, and pipeline management, then provide an example of how these solutions can come together to address those challenges.

## Current Challenges 

**Image Management**- One of my first roles as a server admin was to build physical servers based on a checklist, then ship those servers out to our remote locations. Later on in my career I began consulting and realized the challenges I ran into in that role, were often experienced by many of my customers. A quick run down of some of those include- 

*Running through a lot of manual steps both in the build and QA of the image
*Inability to track changes or history of various images
*My personal favorite- "Use this image, it was build 5 years ago, not sure what's on it, but it just works" 

Tools like Packer provide a codified method of building images and when that code is stored in a VCS, a lot of the common challenges noted can be addressed. Packer is a powerful tool that makes image deployment significantly easier, but on its own it may not be enough for large scale organizations that are collaborating across teams and multiple clouds with varying images that are constantly being updated. 
