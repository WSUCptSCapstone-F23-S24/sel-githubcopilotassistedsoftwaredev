# SEL - GitHub CoPilot Software Development

## Project summary
With the creation of generative AI tools, specifically GitHub CoPilot, we aim to determine just how helpful these tools can be for software developers.

Our project assumes the form of a comprehensive study aimed at analyzing the transformative potential of recent advancements in AI, with a particular focus on GitHub CoPilot, in revolutionizing the software development process. The primary objective of our study is to assess the efficacy and quality of software development when utilizing GitHub CoPilot as an assisting tool. To accomplish this, we divide our team into one subteam that uses CoPilot and one subteam that uses no generative AI tools. Comparing and contrasting the experiences between these teams will clearly show exactly how effective AI tools can be at assisting software developers.

## Repository Structure
Because our team is split into two groups, we have CoPilot folder and a NoAI folder. As one would expect, the work completed using CoPilot is in the CoPilot folder, and the work completed without the use of generative AI is in the NoAI folder. Additionally, any open issues or branches that aren't related to documentation are labeled similarly.

## Installation
This project is coded in python, and as such requires a python installation.

### Prerequisites
Python 3.10+

### Add-ons
PyQt6 - Front-end UI library.

### Installation Steps
This project has two version which are the CoPilot and NoAI. 

To download the CoPilot Version for this most recent sprint:
```Download the Yelp Reviews.json files, these are too large to be uploaded to github.

Clone the repository
git clone https://github.com/WSUCptSCapstone-F23-S24/sel-githubcopilotassistedsoftwaredev.git

Navigate to the project directory
cd CaseStudy2-approach2-CoPilot

Install dependencies
pip install -r Requirements.txt

Add the Yelp .json files to the workspace

Run the application
python main.py
```
To download the NoAI Version for this most recent sprint:
```Download the Yelp Reviews.json files, these are too large to be uploaded to github.

Clone the repository
git clone https://github.com/WSUCptSCapstone-F23-S24/sel-githubcopilotassistedsoftwaredev.git

Navigate to the project directory
cd CaseStudy2-approach2-NoAI

Install dependencies
pip install -r Requirements.txt

Add the Yelp .json files to the workspace

Run the application
python app.py
```

## Case Study 1: Front-End UI Application
[CoPilot Branch](https://github.com/WSUCptSCapstone-F23-S24/sel-githubcopilotassistedsoftwaredev/tree/CaseStudy1-Copilot)

[NoAI Branch](https://github.com/WSUCptSCapstone-F23-S24/sel-githubcopilotassistedsoftwaredev/tree/CaseStudy1-NoAI)

### Functionality
This front-end application serves as a place to gather useful data about business in a certain area. A user of this application can accomplish the following.

* Search by State, City, and ZIP Code.
* View statistics about the ZIP Code searched.
* View successful businesses within the specified location.
* View popular businesses within the specified location.
* View businesses within the specified location with details including:
  * Name
  * Address
  * Rating
  * Number of reviews
  * Average rating 
  * Total number of check-ins
* Search businesses by category.
* View businesses within the specified category.

### Known Problems
Currently, the application has no database back-end, so data on the front-end is either inaccurate or nonexistant. The back-end implementation has now been completed in Case Study 1 Part 2, below.

## Case Study 1 Part 2: Backend-End UI Application (no sql)
[CoPilot Branch](https://github.com/WSUCptSCapstone-F23-S24/sel-githubcopilotassistedsoftwaredev/tree/CaseStudy2-CoPilot)

[NoAI Branch](https://github.com/WSUCptSCapstone-F23-S24/sel-githubcopilotassistedsoftwaredev/tree/CaseStudy2-NoAI)

### Functionality
This back-end implementation complements the previously made front-end GUI. All features explained above are now fully implemented using built-in python datatypes.

### Known Problems
The implementation for this approach utilizes dictionaries and other standard python data structures. 

## Case Study 1 Part 2: Backend-End UI Application (PostgreSQL)
[CoPilot Branch](https://github.com/WSUCptSCapstone-F23-S24/sel-githubcopilotassistedsoftwaredev/tree/CaseStudy2-approach2-CoPilot)

[NoAI Branch](https://github.com/WSUCptSCapstone-F23-S24/sel-githubcopilotassistedsoftwaredev/tree/CaseStudy2-NoAI/Approach%202)

### Functionality
This back-end implementation complements the previously made front-end GUI. All features explained above are now fully implemented using a PostgreSQL database.

### Known Problems
The implementation for this approach utilizes a PostgreSQL database. Check each branch to see specifics on the structure of the database.

## Additional Documentation
[Project Report](https://1drv.ms/w/s!AtV6T549EE8KhMxf6vPN9ng4BZY9ig?e=nBTRYv)

[Metric Tracking Document](https://docs.google.com/spreadsheets/d/1ymLoq1peAggIlSSYoW2vvT3tpB8PEj7SNVEC08-0Hpo/edit?usp=sharing)

[Case Study Summaries](https://docs.google.com/document/d/1Tt-thmhBi_Uz75E4v8us9cPoAFDKK6eRIz1PHmFuLgI/edit?usp=sharing](https://docs.google.com/document/d/17b-JeKfkEkzT6vpQcVrDUf18a8jq0FybYlhqRsI1-eY/edit?usp=sharing)](https://docs.google.com/document/d/17b-JeKfkEkzT6vpQcVrDUf18a8jq0FybYlhqRsI1-eY/edit?usp=sharing))

[Sprint Report 1](https://github.com/WSUCptSCapstone-F23-S24/sel-githubcopilotassistedsoftwaredev/blob/main/Sprint1Report.md)

[Sprint Report 2](https://github.com/WSUCptSCapstone-F23-S24/sel-githubcopilotassistedsoftwaredev/blob/main/Sprint2Report.md)

[Sprint Report 3](https://github.com/WSUCptSCapstone-F23-S24/sel-githubcopilotassistedsoftwaredev/blob/main/Sprint3Report.md)



## License
Copyright (c) 2023 Joshua Burk, Joshua Maloy, Ryan Luders, Jay-Ar Arsenio

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
