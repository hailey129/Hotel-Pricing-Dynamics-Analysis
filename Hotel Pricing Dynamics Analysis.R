rm(list=ls())

library(tidyverse)
library(modelsummary)
library(lspline)

#########################################################################
### Part 1
df <- read_csv('hotelbookingdata.csv')

# Rename s_city to city, center1distance to distance
df <- rename(df,city = s_city,distance = center1distance)

city_data <- filter(df, city == 'Rome', year == 2017 & month == 11 & weekend == 0) |>
  separate(accommodationtype, '@', into = c('garbage', 'acc_type')) |>
  separate(distance, ' ', into = c('distance', 'miles')) |>
  select (-garbage, -miles) |>
  filter(acc_type == 'Hotel') |>
  select(hotel_id, distance, price, neighbourhood, starrating)|>
  mutate(distance = as.numeric(distance))|>
  distinct()

datasummary_skim(city_data)

#########################################################################
### Part 2
# Create histograms of distance and price variables and their scatterplot

# Histogram of the price variable
ggplot(data = city_data) +
  geom_histogram(aes(x=price), fill='lightblue', color='black')+
  labs(x='Price', y = 'Count')+
  theme_bw()

# Histogram of the distance variable
ggplot(data = city_data) +
  geom_histogram(aes(x=distance), fill='lightblue', color='black')+
  labs(x='Distance', y = 'Count')+
  theme_bw()

# SCATTERPLOT
# Include the following layer specifications for x and y axis and the theme
# Adjust limits and breaks 

ggplot(data = city_data) +
  geom_point((aes(x=distance, y=price)), fill = 'bisque3', color = 'black', shape = 21, size = 2)+
  scale_x_continuous(limits=c(0, 18), breaks=seq(0, 18, by=1)) +
  scale_y_continuous (limits = c(0, 1200), breaks = seq(0, 1200, by = 50))+
  labs(x='Distance', y='Price')
theme_bw()

# Evaluate the data of distance > 10 miles and price > 500
ev_distance <- filter(city_data, distance > 10)
ev_price <- filter(city_data, price > 500)

# Restrict the sample 
city_data <- filter(city_data, distance <= 10 & starrating %in% c(3, 3.5, 4))

ggplot(data = city_data) +
  geom_point((aes(x=distance, y=price)), fill = 'bisque3', color = 'black', shape = 21, size = 2)+
  scale_x_continuous(limits=c(0, 10), breaks=seq(0, 10, by=1)) +
  scale_y_continuous (limits = c(0, 500), breaks = seq(0, 500, by = 50))+
  labs(x='Distance', y='Price')
theme_bw()

#########################################################################
### Part 2.

# Find observations with extreme values and decide what to do with them
# Implement your decisions to arrive at the final sample that you will use for modelling

###
# Produce the scatterplot of the final sample in levels and name it p1
# ADJUST x and y scales to make the plot look good

p1 <- ggplot(data = city_data) +
  geom_point(aes(x = distance, y = price), fill = 'bisque3', color = 'black', shape = 21, size = 2) +
  scale_x_continuous(limits=c(0, 10), breaks=seq(0, 10, by=1)) +
  scale_y_continuous (limits = c(0, 600), breaks = seq(0, 600, by = 50)) +
  labs(x = 'Distance', y = 'Price')
theme_bw()

p1
#########################################################################
### Part 3

# LOWESS NONPARAMETRIC REGRESSION

# Add a Lowess (non-parametric) regression line to the scatterplot
p1 + geom_smooth(aes(x = distance, y = price), method = 'loess', color = 'blue', se = FALSE)

# LINEAR REGRESSION

# Fit a linear regression model
reg1 <- lm(price ~ distance, data = city_data)

summary(reg1)  # generate the regression result in a table format

# Scatter plot and regression line
p1 + geom_smooth(aes(x = distance, y = price), method = 'lm', formula = y ~ x, color = 'red', se = FALSE) # Adds linear regression line

# Compute predicted price and residuals
city_data$predicted_price <- predict(reg1)

city_data$residuals <- city_data$price - city_data$predicted_price

#########################################################################
### Part 4

### TRANSFORMATIONS

# Create logged variables
city_data$ln_price <- log(city_data$price)
city_data$ln_distance <- log(city_data$distance)

# Produce histograms

# LOG PRICE

ggplot(city_data, aes(x = ln_price)) + 
  geom_histogram(bins = 30, fill = "lightblue", color = "black") + 
  labs(title = "Histogram of Log-Price", x = "Log-Price", y = "Count")
theme_bw()

# LOG DISTANCE
ggplot(city_data, aes(x = ln_distance)) + 
  geom_histogram(bins = 30, fill = "lightblue", color = "black") + 
  labs(title = "Histogram of Log-Distance", x = "Log-Distance", y = "Count")
theme_bw()


# Scatterplots
# USE THE SAME GRAPH SPECIFICATION AS IN PART 2.2

# LOG_LOG scatter

ggplot(city_data, aes(x = ln_distance, y = ln_price)) +
  geom_point(fill = 'bisque3', color = 'black', shape = 21, size = 2) +
  labs(x = 'Log of Distance', y = 'Log of Price') +
  theme_bw()


# LEVEL_LOG scatter: 
# Log-transform distance, price remains in original form 
# X-axis is log-transformed distance, Y-axis is original price

ggplot(city_data, aes(x = ln_distance, y = price)) +  
  geom_point(fill = 'bisque3', color = 'black', shape = 21, size = 2) +
  labs(x = 'Log of Distance', y = 'Price') +  
  theme_bw()


# LOG-LEVEL scatter
ggplot(city_data, aes(x = distance, y = ln_price)) +  
  geom_point(fill = 'bisque3', color = 'black', shape = 21, size = 2) +
  labs(x = 'Distance', y = 'Log of Price') +  
  theme_bw()

### Choose the best model => log-log 

# Produce scatter plot + lowess fit
ggplot(city_data, aes(x = ln_distance, y = ln_price)) + 
  geom_point(fill = 'bisque3', color = 'black', shape = 21, size = 2) + 
  geom_smooth(method = "loess", formula = 'y ~ x', se = FALSE) +  
  labs(x = 'Log of Distance', y = 'Log of Price') + 
  theme_bw()  

# Run the regression for your chosen model (call it reg2)

# Produce scatter plot + estimated regression line

reg2 <- lm(ln_price ~ ln_distance, data = city_data)  

ggplot(city_data, aes(x = ln_distance, y = ln_price)) +  
  geom_point(fill = 'bisque3', color = 'black', shape = 21, size = 2) +
  geom_smooth(method = 'lm', se = FALSE, formula = 'y ~ x', color = 'red') +
  labs(x = 'Log of Distance', y = 'Log of Price') + 
  theme_bw()

# Show the summary of regression results
summary(reg2)

#########################################################################
### Part 5

# LINEAR SPLINE MODEL IN LEVELS
# 
# Base on the loess regression we choose a cutoff (about 2 miles from the city centre)
cutoff <- 2  # defining the cutoff point as 2 miles

# Estimate the model and do scatterplot + regression line (call it reg3) using lspline function
reg3 <- lm(price ~ lspline(distance, cutoff), data = city_data)

summary(reg3)  # display the regression output

# Create scatterplot with regression line

ggplot(data = city_data, aes(x = distance, y = price)) +
  geom_point(color = "blue") + 
  geom_smooth(formula = y ~ lspline(x, cutoff), method = "lm", color = "red", se = FALSE) +
  labs(x = "Distance from city center (miles)", y = "Price") +
  theme_bw()


# !!! I argue with 1 more model: log-level for the spline

# I estimate the model and call it reg4
reg4 <- lm(ln_price ~ lspline(distance, cutoff), data = city_data)

summary(reg4) # display the regression output

ggplot(data=city_data, aes(x = distance, y = ln_price)) +
  geom_point(color = "blue") +
  geom_smooth(formula = y ~ lspline(x, cutoff), method = "lm", color = "red", se = FALSE) +
  labs(x = "Distance from the city center (miles)", y = "Log of Price") +
  theme_bw()


#########################################################################
### Part 6

#Comparing models
msummary(list(reg1, reg2, reg4))

# Choose the best model and argue why this model explain the data better than other models

# USE YOUR CHOSEN BEST MODEL FROM NOW ON
# Compute residuals and fitted values

city_data$lnprice_hat <- reg4$fitted.values  # Fitted (predicted) values

city_data$lnprice_resid <- reg4$residuals    # Residuals


# Get the hotels that are the most UNDERPRICED = top deals = green
city_data |>
  slice_min(lnprice_resid, n = 5) |>  # Select the row with the n smallest residuals
  select(hotel_id, price, distance, lnprice_hat, lnprice_resid)  # Only interested in specific columns

# Get the hotels that are the most OVERPRICED = bottom deals = red
city_data |>
  slice_max(lnprice_resid, n = 5) |>  # Select the row with the n largest residuals
  select(hotel_id, price, distance, lnprice_hat, lnprice_resid)  # Only interested in specific columns


# Create the scatter plot with five best deals in green and five worst deals in red
# All other data points must be of the same colour

# Create bottom5 and top5 indicator variables using ifelse()

city_data$deal_indicator <- ifelse(city_data$lnprice_resid %in% head(sort(city_data$lnprice_resid, decreasing = FALSE), 5), 'top5',
                                   ifelse(city_data$lnprice_resid %in% head(sort(city_data$lnprice_resid, decreasing = TRUE), 5), 'bottom5', 'other'))
# Corrected from tail to head for correct sorting


# Check the new table after creating:
table(city_data$deal_indicator)

# Create the scatter plot

ggplot(data = city_data, aes(x = distance, y = ln_price)) + 
  geom_point(size = 2, shape = 16, alpha = 0.6, color = "gray") +  # Plot all points as gray by default
  
  # Highlight the bottom 5 (overpriced) hotels in red
  geom_point(data = filter(city_data, deal_indicator == 'bottom5'),
             size = 3, color = 'red', shape = 16, alpha = 1) +
  
  # Highlight the top 5 (underpriced) hotels in green
  geom_point(data = filter(city_data, deal_indicator == 'top5'),
             size = 3, color = 'green', shape = 16, alpha = 1) +
  
  # Add the spline regression line (log-level model)
  geom_line(data = city_data, aes(x = distance, y = predict(reg4, city_data)), 
            color = "black", size = 1) + 
  
  # Add labels
  labs(x = "Distance from city centre (miles)", 
       y = "Log Price (US dollars)", 
       title = "Log-Level Model: Hotel Prices vs Distance with Best and Worst Deals Highlighted") +
  
  theme_minimal() + 
  theme(legend.position = "none")





