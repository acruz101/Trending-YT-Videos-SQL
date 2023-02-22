# Trending-YT-Videos-SQL
A MySQL Project

Dataset Link: https://www.kaggle.com/datasets/datasnaek/youtube-new

MySQL Script to Create Reports for Multiple Business Scenarios:
+ Analyze Youtube video trending patterns (i.e. which category trends the most).
+ Understand viewers’ affinities for various categories/channels/tags.

In this project, I used MySQL to create a relational database, import the data from CSV and JSON files, and then extract different information to answer different business questions. The main questions include: 
+ **Top 10 Video Categories For Each Day of the Week**

    Query:

    <img width="613" alt="Screenshot 2023-02-20 at 10 17 15 PM" src="https://user-images.githubusercontent.com/47541514/220262913-8b5783ca-adae-414e-b636-ca841e4f3721.png">

    Result (Below is a preview and not the full result):

    <img width="306" alt="Screenshot 2023-02-20 at 10 17 44 PM" src="https://user-images.githubusercontent.com/47541514/220262995-8d8b52b7-e8d5-447e-bea1-c5a51a376770.png">

+ **Top Trending Channel for each Category (and their average statistics)**

    Query:

    <img width="752" alt="Screenshot 2023-02-20 at 10 22 27 PM" src="https://user-images.githubusercontent.com/47541514/220263795-726125be-c46f-42db-b62d-a5c3755d2832.png">

    Result (Below is the full result):

    <img width="737" alt="Screenshot 2023-02-20 at 10 22 54 PM" src="https://user-images.githubusercontent.com/47541514/220263886-a8872992-1db1-446c-b36f-0773b964ee4f.png">

+ **The Top Trending Channel for each category from Mon to Fri**

    Query:

    <img width="412" alt="Screenshot 2023-02-20 at 10 26 00 PM" src="https://user-images.githubusercontent.com/47541514/220264407-471822a6-1c88-4d5f-b1d1-9d2a78afef9e.png">

    Result (Below is a preview and not the full result):

    <img width="350" alt="Screenshot 2023-02-20 at 10 26 23 PM" src="https://user-images.githubusercontent.com/47541514/220264494-a883b02d-0709-4d2b-ab1a-231b551ea476.png">

+ **Analyze the Channel with Most Trending Videos in the US**
  + **Find Average Daily Views with Most Trending Videos**
  + **Compare Average Daily Views with the Previous Day by Calculating % Difference**

      + Query:


      <img width="506" alt="Screenshot 2023-02-20 at 10 29 29 PM" src="https://user-images.githubusercontent.com/47541514/220265013-c7f6f5c7-10d9-422f-8d56-81b3a818cab4.png">

      + Result (Below is a preview and not the full result):



      <img width="200" alt="Screenshot 2023-02-20 at 10 30 48 PM" src="https://user-images.githubusercontent.com/47541514/220265227-aaa6ae95-968b-46c3-9893-3c54a499fb33.png">

      + Query:



      <img width="768" alt="Screenshot 2023-02-20 at 10 31 30 PM" src="https://user-images.githubusercontent.com/47541514/220265355-3843600a-432f-4d7a-83de-36540ff004b9.png">

      + Result (Below is a preview and not the full result):



      <img width="367" alt="Screenshot 2023-02-20 at 10 32 19 PM" src="https://user-images.githubusercontent.com/47541514/220265502-5cfe5fc4-02e2-44ba-9c88-4fd09d1a0000.png">

(I used Python to extract data from JSON files, convert them into CSV files, so I could export them into MySQL database.)
