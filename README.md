# Trending-YT-Videos-SQL [In Progress]
A MySQL Project

Dataset Link: https://www.kaggle.com/datasets/datasnaek/youtube-new

MySQL Script to Create Reports for Multiple Business Scenarios:
+ Analyze Youtube video trending patterns (i.e. which category trends the most).
+ Understand viewers’ affinities for various categories/channels/tags.

In this project, I used MySQL to create a relational database, import the data from CSV and JSON files, and then extract different information to answer different business questions. The main questions include: 
+ Top 10 Video Categories For Each Day of the Week
+ Top Trending Channel for each Category (and their average statistics)
+ The Top Trending Channel for each category from Mon to Fri
+ Analyze the Channel with Most Trending Videos in the US
  + Find Average Daily Views with Most Trending Videos
  + Compare Average Daily Views with the Previous Day by Calculating % Difference

(I used Python to extract data from JSON files, convert them into CSV files, so I could export them into MySQL database.)
