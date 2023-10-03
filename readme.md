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
```python
pip3 install pyqt6 # Install needed library
python main.py     # Run code
```

## Case Study 1: Front-End UI Application

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
Currently, the application has no database back-end. This will be completed in the future. Additionally, many features are incomplete. The only features developed as yet are:
* Search by State, City, and ZIP Code.
* View statistics about the ZIP Code searched.

## Additional Documentation
[Metric Tracking Document](https://docs.google.com/spreadsheets/d/1ymLoq1peAggIlSSYoW2vvT3tpB8PEj7SNVEC08-0Hpo/edit?usp=sharing)

## License
Copyright (c) 2023 Joshua Burke, Joshua Maloy, Ryan Luders, Jay-Ar Arsenio

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
