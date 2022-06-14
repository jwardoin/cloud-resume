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

**Tech used:** HTML, CSS, JavaScript - AWS S3, Route53, CloudFront - Github Actions

Built an HTML page with the content of my resume and styled it with CSS. These files were placed in a public AWS S3 bucket with static webhosting enabled. My domain was purchased and hosted using AWS Route53. Then, I created a CloudFront distribution, set the origin as my public S3 bucket, and pointed my domain to it with Route53. After building the backend, I wrote a small asynchronous function using Javascript that made a GET request to my backend and returned the needed values and set it to run on load within my HTML file. Once all of the pieces were in place, I pushed the completed poduct to GitHub. Finally, I setup a pipeline using GitHub Actions to update my static website files in the S3 bucket as I push new changes through to Git.

### Backend

**Tech used:** AWS Lambda, API Gateway, DynamoDB, IAM, S3, CloudWatch - Terraform, Python(Boto3), Cypress, GitHub Actions

Created a DynamoDB table to hold the visitor count. Then, using Python and the Boto3 library, I created a Lambda function that increments the visitor counter every time it's triggered and returns the most recent amount and assigned it an IAM role with DynamoDB permissions using the principle of least privilege. Next, I deployed a CORS enabled REST API with API Gateway, enabled CloudWatch to log error codes for debugging, and gave it permission to invoke the Lambda function. Finally, I recreated the architecure using Terraform, pushed it Github, and setup a pipeline that zips my most recent Python code, stores it in an S3 bucket, and then applies code and infrastructure changes with Terraform.

## On the Roadmap

### General

- |In Progress| Using one GitHub Repository for the whole stack - The challenge called for two separate repos, but I think a single repo with more specifically tailored GitHub Actions would be easier to manage.

- Terraform - break infrastructure code into modules and take advantage of HCL variables

- Observability & Monitoring - I'm only using CloudWatch to monitor and log API errors at the moment - in the future, I would like to broaden the scope of my monitoring and observability in a meaningful way

### Frontend 

- |Completed| <del>Semantic HTML & Responsive CSS - in its current state, the HTML and CSS are just code vomit - they work on desktop browsers and that is about it. Since viewing will likely occur on mobile devices, I think it is important that I update this as soon as possible.</del>
  - rebuilt site with proper tags and DRY code. Used relative lengths to keep site elastic and media queries to keep site looking good on all devices  

- |Completed| <del>Caching - currently, the CloudFront distribution does not have caching setup properly for the application, so the visitor counter will continue updating with each refresh(and with testing too). I acknowledge that this is unideal and plan to figure out the best way to fix this ASAP.</del>
  - implemented saving visitor count to localStorage

- |Completed| <del>Connect resume to my portfolio site</del>

- Infrastructure as Code for the frontend - If I was able to troubleshoot all of the issues and make Terraform work for my backend, I could certainly do it for my frontend. This would allow me to control all of my current infrastructure in one place and would work well with a single repo as mentioned above.

- Plan and build directory system to serve landing pages for tailored resumes - Since this challenge uses some skills for a variety of different potential job titles, I'd like to have multiple resumes for all of the different jobs titles I may apply for, easily accessible from myurl/jobtitle

### Backend

- |Completed| <del>Integrate automated testing - I wrote a small smoke test using Cypress that passes if my API returns the proper values. Since I manually tested the code until I knew it was working and then  pushed it, I never *needed* to integrate the testing into my pipeline, but this would be especially useful for an application that will be updated with any regularity.</del>
  - Cypress test now runs when backend code changes are pushed - backend code is only deployed to production if all test pass

- Build more robust testing - my end-to-end test only checks that my Lambda function is returning status code 200 to the API; I would like for it to also test that the json body is returning the proper values - I would also like to add some way to test my code without using my production API
<hr>

## Final Thoughts

My understanding of how web applications work went from lots and lots of small pieces of information that didn't really fit together to larger chunks of working knowledge. This challenge truly helped me connect the pieces and grasp where each part of the stack begins and where it ends. 

## Examples:
Take a look at these couple examples that I have in my own portfolio:

**CodeWars:** https://github.com/jwardoin/code-wars-problems

**MAA-Invoicer:** https://github.com/jwardoin/maa-invoicer


