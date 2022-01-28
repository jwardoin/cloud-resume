# My Cloud Resume
![flowchart for this project](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/wg1wlojm698kntcrysox.jpeg)
<hr>
Currently, my Cloud resume is separated into repos for each the front and backend. 
I plan to migrate them both here and update the pipeline accordingly. 

[Check out my blog post](https://dev.to/jwardoin/my-cloud-resume-challenge-48n1) to see how it is made and all of the changes I plan to make while.

#### You can view the current site here:
[resume.jordanardoin.com](resume.jordanardoin.com)

## How It's Made:

### Frontend

**Tech used:** HTML, CSS, Javascript - AWS S3, Route53, CloudFront - Github Actions

Built an HTML page with the content of my resume and styled it with CSS. These files were placed in a public AWS S3 bucket with static webhosting enabled. My domain was purchased and hosted using AWS Route53. Then, I created a CloudFront distribution, set the origin as my public S3 bucket, and pointed my domain to it with Route53. After building the backend, I wrote a small asynchronous function using Javascript that made a GET request to my backend and returned the needed values and set it to run on load within my HTML file. Once all of the pieces were in place, I pushed the completed poduct to GitHub. Finally, I setup a pipeline using GitHub Actions to update my static website files in the S3 bucket as I push new changes through to Git.

### Backend

**Tech used:** AWS Lambda, API Gateway, DynamoDB, IAM, S3, CloudWatch - Terraform, Python(Boto3), Cypress, GitHub Actions

Created a DynamoDB table to hold the visitor count. Then, using Python and the Boto3 library, I created a Lambda function that increments the visitor counter every time it's triggered and returns the most recent amount and assigned it an IAM role with DynamoDB permissions using the principle of least privilege. Next, I deployed a CORS enabled REST API with API Gateway, enabled CloudWatch to log error codes for debugging, and gave it permission to invoke the Lambda function. Finally, I recreated the architecure using Terraform, pushed it Github, and setup a pipeline that zips my most recent Python code, stores it in an S3 bucket, and then applies code and infrastructure changes with Terraform.

## On the Roadmap

- <<In Progress>> Using one GitHub Repository for the whole stack - The challenge called for two separate repos, but I think a single repo with more specifically tailored GitHub Actions would be easier to manage.

- <<In Progress>> Integrate automated testing - I wrote a small smoke test using Cypress that passes if my API returns the proper values. Since I manually tested the code until I knew it was working and then  pushed it, I never *needed* to integrate the testing into my pipeline, but this would be especially useful for an application that will be updated with any regularity.

- <<Completed>> <del>Semantic HTML & Responsive CSS - in its current state, the HTML and CSS are just code vomit - they work on desktop browsers and that is about it. Since viewing will likely occur on mobile devices, I think it is important that I update this as soon as possible.</del>

- Caching - currently, the CloudFront distribution does not have caching setup properly for the application, so the visitor counter will continue updating with each refresh(and with testing too). I acknowledge that this is unideal and plan to figure out the best way to fix this ASAP.

- Infrastructure as Code for the frontend - If I was able to troubleshoot all of the issues and make Terraform work for my backend, I could certainly do it for my frontend. This would allow me to control all of my current infrastructure in one place and would work with a single repo as mentioned above.
<hr>


<!-- ## Final Thoughts

TODO -->

<!-- ## Examples:  -->

