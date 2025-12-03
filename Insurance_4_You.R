# Import the necessary libraries.
library(tidyverse)

# Import the insurance data set
health <- read.csv(file.choose(), header=TRUE)

# View the data frame.
head(health)
str(health)
summary(health)

# Compare age (x-variable) and charges (y-variable).
ggplot(health,
       mapping=aes(x=age, y=charges)) +
  geom_point()

# Remove outliers (>50,000).
new_health <- filter(health, charges<50000)
ggplot(new_health,
       mapping=aes(x=age, y=charges)) +
  geom_point()

# Compare age and charges based on sex.
ggplot(new_health,
       mapping=aes(x=age, y=charges)) +
  geom_point(color='purple',
             alpha=0.75,
             size=2.5) +
  scale_x_continuous(breaks=seq(0, 70, 5), "Age of the Individual") +
  scale_y_continuous(breaks=seq(0, 55000, 5000), "Monthly charges (in $)") +
  labs(title="Relationship between age and charges",
       subtitle="A survey from a health insurance provider") +
  facet_wrap(~sex)

# Compare age and charges based on region.
ggplot(new_health,
       mapping=aes(x=age, y=charges)) +
  geom_point(color='blue',
             alpha=0.75,
             size=2.5) +
  scale_x_continuous(breaks=seq(0, 70, 5), "Age of the Individual") +
  scale_y_continuous(breaks=seq(0, 55000, 5000), "Monthly charges (in $)") +
  labs(title="Relationship between age and charges",
       subtitle="A survey from a health insurance provider") + 
  facet_wrap(~region)

#Compare age and charges based on children.
ggplot(new_health,
       mapping=aes(x=age, y=charges)) +
  geom_point(color='red',
             alpha=0.75,
             size=2.5) +
  scale_x_continuous(breaks=seq(0, 70, 5), "Age of the Individual") +
  scale_y_continuous(breaks=seq(0, 55000, 5000), "Monthly charges (in $)") +
  labs(title="Relationship between age and charges",
       subtitle="A survey from a health insurance provider") + 
  facet_wrap(~children)

#Add a smoker variable
ggplot(new_health, 
       mapping=aes(x=age, y=charges, col=smoker)) +
  geom_point() +
  scale_x_continuous(breaks=seq(0, 70, 5), "Age of member") +
  scale_y_continuous(breaks=seq(0, 55000, 5000), "Monthly charges")

# age on a histogram.
ggplot(health, aes(x=age)) +
  geom_histogram(stat='count',
                 fill='blue')

# Plot children on a histogram.
ggplot(health, aes(x=children)) +
  geom_histogram(stat='count',
                 fill='red')

# region and sex on a stacked barplot.
ggplot(health, aes(x=region, fill=sex)) +
  geom_bar()

# smoker vs sex.
ggplot(health, aes(x=smoker, fill=sex)) +
  geom_bar(position='dodge') +
  scale_fill_manual(values=c('purple', 'orange')) +
  labs(title="Count of male and female smokers")

# Plot BMI and sex on a side-by-side boxplot.
ggplot(health, aes(x=sex, y=bmi)) +
  geom_boxplot()

#  BMI and region on a side-by-side violinplot.
ggplot(health, aes(x=region, y=bmi)) +
  geom_violin(fill='orange')

# BMI vs smoker plot.
ggplot(health, aes(x=smoker, y=bmi)) +
  geom_boxplot(fill='green',
               notch=TRUE,
               outlier.color='blue')


travelmode <- read.csv(file.choose(), header=TRUE)
head(travelmode)
tail(travelmode)


# View the data set in a new window in RStudio as an Excel-style sheet.
View(travelmode)

# View the dimensions of the data set i.e. the number of rows and columns.
dim(travelmode)

# View the titles or names of the columns in the data set.
colnames(travelmode)
names(travelmode)

# Determine the structure of the data set.
str(travelmode)
glimpse(travelmode)
as_tibble(travelmode)

# To search for missing values in a data set.
travelmode[is.na(travelmode)]

# To search for missing values in a specific column of a data set.
is.na(travelmode$size)

# To search for missing values in a data set.
sum(is.na(travelmode))

# To search for missing values in a specific column of a data set.
sum(is.na(travelmode$size))

# summary statistics of the data set.
summary(travelmode)
skim(travelmode)

# creates a downloadable HTML file containing summary stats of the data.
DataExplorer::create_report(travelmode)

# Review/sense-check the data set.
as_tibble (travelmode)

# Delete columns X and gender.
travelmode <- subset(travelmode,
                     select = -c(X, gender))

# View the column names.
names(travelmode)

# Change the names of the columns.
travelmode <- travelmode %>%
  rename (waiting_time = wait, 
         vehicle_cost = vcost, 
         travel_time = travel, 
         general_cost = gcost, 
         family_size = size)
head(travelmode)


# Calculate the total costs for car clients only, and add these values to the initial data set.

# Find total costs for car clients only in the data frame.
car_costs <- subset(travelmode,
                    mode=='car')

# Add a column with total costs.
car_costs <- car_costs %>%
  mutate(total_cost = vehicle_cost + general_cost) 

# View the result.
head(car_costs)

# Add total_cost column to the travelmode data frame.
joined_travelmode <- left_join(travelmode,
                               car_costs)
# View the result.
head(joined_travelmode)

# Confirm number of rows.
dim(joined_travelmode)

# Create data frames for each travel mode for members with families.
# Travelling by air.
# Create new a data frame as travelmode_air.
air_family <- select(filter(travelmode,
                            mode=='air',
                            family_size>='2'), 
                     c(individual,
                       choice:family_size))
head(air_family)

# Travelling by train.
train_family <- select(filter(travelmode,
                              mode=='train',
                              family_size>='2'), 
                       c(individual,
                         choice:family_size))
head(train_family)

# Travelling by bus.
bus_family <- select(filter(travelmode,
                            mode=='bus',
                            family_size>='2'),
                     c(individual,
                       choice:family_size))
head(bus_family)

# Travelling by car.
car_family <- select(filter(travelmode,
                            mode=='car',
                            family_size>='2'), 
                     c(individual,
                       choice:family_size))
head(car_family)

# Find the preferred travel mode for families.
air_family %>% 
  count(choice)

train_family %>% 
  count(choice)

bus_family %>% 
  count(choice)

car_family %>% 
  count(choice)

# Calculate the average vehicle cost and general costs for members with families.

# For cars:
mean_car_costs <- summarise(car_family,
                            mean_VC=mean(vehicle_cost),
                            mean_GC = mean(general_cost))
mean_car_costs

# For bus:
mean_bus_costs <- summarise(bus_family,
                            mean_VC=mean(vehicle_cost),
                            mean_GC = mean(general_cost))
mean_bus_costs

# For train:
mean_train_costs <- summarise(train_family,
                              mean_VC=mean(vehicle_cost),
                              mean_GC = mean(general_cost))
mean_train_costs

# Create a data frame that contains this data for land-based travel modes, arranged by mean general costs.
mean_land_costs <- rbind(mean_car_costs,
                         mean_bus_costs,
                         mean_train_costs)
mean_land_costs

# Add a column containing the vehicle type.
vehicle <- c('car', 'bus', 'train')

# Add the column names to the data frame.
mean_costs <- cbind(vehicle,
                    mean_land_costs)
mean_costs

# Set in descending order from the highest mean general cost down.
arrange(mean_costs, desc(mean_GC))


#seatbelt
seatbelt <- read.csv(file.choose(), header=T)

# Sense check the data set.
as_tibble(seatbelt)
View(seatbelt)

# Determine the sum of missing values 
sum(is.na(seatbelt))
sum(is.na(seatbelt$seatbelt))

# Replace NA with 0.
seatbelt[is.na(seatbelt)] = 0
head(seatbelt)
sum(is.na(seatbelt$seatbelt))

# Determine the descriptive statistics.
summary(seatbelt)
DataExplorer::create_report(seatbelt)

# Drop unnecessary columns (e.g. column X).
seatbelt_df <- subset(seatbelt, select=-c(1))

# Create a subset of the data frame with only numeric columns.
seatbelt1 <- seatbelt_df %>% keep(is.numeric)
head(seatbelt1)

# Round all the columns to 2 decimal places.
seatbelt1 <- round(seatbelt1, 2)
head(seatbelt1)


# visualise data with boxplot to determine normal distribution of separate columns.
boxplot(seatbelt1$miles)
boxplot(seatbelt1$fatalities)
boxplot(seatbelt1$income)
boxplot(seatbelt1$age)
boxplot(seatbelt1$seatbelt)


# Calculate the sum of all the columns.
aseatbelt1 <- apply(seatbelt1, 2, sum)
aseatbelt1 <- round(aseatbelt1, 2)
head(aseatbelt1)


# Calculate the min of all the columns.
sseatbelt1 <- sapply(seatbelt1, min)
sseatbelt1 <- round(sseatbelt1, 2)
sseatbelt1


# Calculate the max of all the columns.
bseatbelt1 <- sapply(seatbelt1, max)
bseatbelt1 <- round(bseatbelt1, 2)
bseatbelt1

# Focus on specific variables 
seatbelt_agg <- select(seatbelt, c('state',
                                   'year',
                                   'miles'))
as_tibble(seatbelt_agg)



# Focus on specific variables with the select() function.
seatbelt_agg2 <- select(seatbelt, c('drinkage',
                                    'year',
                                    'miles'))
as_tibble(seatbelt_agg2)

# Plot increase seatbelt usage correlates with lower fatality rates
seatbelt_real <- seatbelt %>% filter(!is.na(seatbelt))
ggplot(seatbelt_real, aes(x = seatbelt, y = fatalities)) +
  geom_point(alpha = 0.5, color = "darkblue") +
  geom_smooth(method = "lm", color = "red") +
  labs(
    title = "True Impact of Seatbelts on Fatalities",
    subtitle = "Higher seatbelt usage (right) correlates with lower fatalities (bottom)",
    x = "Seatbelt Usage Rate (0.0 - 1.0)",
    y = "Fatalities per Million Miles"
  ) +
  theme_minimal()


#police
police <- read.csv(file.choose(), header=T)

# View the data frame.
as_tibble(police)
dim(police)
View(police)

# Determine if there are missing values. 
police[is.na(police)] 
sum(is.na(police))

# Delete all the records with missing values.
police_new <-na.omit(police)

# View the result.
head(police_new)
dim(police_new)
sum(is.na (police_new))

# Determine the descriptive statistics.
summary(police_new)

# Drop unnecessary columns.
police_df <- select(police_new, -c('X', 'idNum', 'date', 'MDC', 'preRace',
                                   'race', 'lat', 'long', 'policePrecinct',
                                   'citationIssued', 'personSearch', 
                                   'vehicleSearch'))
colnames(police_df)
dim(police_df)

# Rename column names with first letter to uppercase.
names(police_df) <- str_to_title(names(police_df))

# View the result.
colnames(police_df)
View(police_df)


# Determine the unique values in each column
unique(police_df$Problem)
unique(police_df$Gender)
unique(police_df$Neighborhood)

# How many offences were suspicious compared to traffic?
barplot(table(police_df$Problem),
        main='Police reports',
        xlab='Offense',
        ylab='Count',
        col='red')

# How many offences were gender based?
barplot(table(police_df$Gender),
        main='Police reports',
        xlab='Gender',
        ylab='Count',
        col='blue')

# How do the neighbourhoods compare?
barplot(table(police_df$Neighborhood),
        main='Police reports',
        xlab='Neighbourhood',
        ylab='Count',
        col='green')

# Determine the number of occurrences for gender and problems.
table(police_df$Gender)            
table(police_df$Problem)
table(police_df$Neighborhood)

# Determine only females with traffic.
nrow(subset(police_df,
            Gender=='Female' & Problem=='traffic'))

# Determine only males with traffic.
nrow(subset(police_df, Gender=='Male' & Problem=='traffic'))

# Determine neighbourhoods with occurrences.
police_df %>% 
  count(Neighborhood, sort=T)

# Create the plot
police_df %>% 
  count(Neighborhood, sort = TRUE) %>% 
    top_n(20, n) %>% 
    ggplot(aes(x = reorder(Neighborhood, n), y = n)) + 
    geom_col(fill = "purple") + 
    coord_flip() + 
    labs(
    title = "Top 20 Neighborhoods by Incident Count",
    x = "Neighborhood",
    y = "Number of Occurrences"
  ) +
    theme_minimal()

# Determine descriptive statistics of the data set.
summary(health)
summary(health$bmi)


# Measure central tendencies of BMI with mean and median.
mean(health$bmi)
median(health$bmi)

# Statistics of extreme values (max and min).
min (health$bmi)
max (health$bmi)

# Measure the variability of BMI values.
max(health$bmi)- min(health$bmi)  

# Function to calculate Q1.
quantile(health$bmi, 0.25)  

# Function to calculate Q2.
quantile(health$bmi, 0.75)   

# Function to calculate IQR.
IQR(health$bmi)    

# Function to determine the variance.
var(health$bmi)

# Function to return the standard deviation.
sd(health$bmi)

# Measure normality in BMI values.
# Q-Q plot:
qqnorm(health$bmi)
# Add a reference line:
qqline(health$bmi, col='red')

# Shapiro-Wilk test:
shapiro.test((health$bmi))

# check for skewness.
skewness(health$bmi)

#Check for kurtosis.
kurtosis(health$bmi)

# Check correlation between BMI and client age.
shapiro.test(health$age)
cor(health$bmi, health$age)