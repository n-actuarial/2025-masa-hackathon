#----------------------- Getting started -----------------------
#Install the package "tidyverse"
install.packages("tidyverse")

#Load the package "tidyverse"
library(tidyverse)

#Install the package "palmerpenguins"
install.packages("palmerpenguins")

#Load the package "palmerpenguins"
library(palmerpenguins)

#View the dataset
View(penguins)

#For this workshop, we will examine the relationship between the following variables:
#1. flipper_length_mm: The length of the penguin's flipper in millimeters (mm)
#2. body_mass_g: The mass of the penguin in grams (g)

#----------------------- Basics of ggplot2 -----------------------
#The 'gg' in 'ggplot2' refers to the grammar of graphics.
#It allows you to ‘speak’ a graph from individual elements, like how words compose a sentence in human speech.

#To create a basic plot, ggplot2 requires at least 3 components:
#Data, Mapping, Layers

#1. Data
#Ideally, the data should be in a tidy rectangular structure such as a data frame or data table

#The first step in any plot is to pass the data to the ggplot() function
#Let us pass the dataset 'penguins' to the ggplot() function
ggplot(data = penguins) 
#This creates a blank canvas for the plot.

#2. Mapping
#The mapping in a ggplot() function defines how your data is mapped to the visual properties (aesthetics) of your plot.
#It is the ‘dictionary’ to translate your data into graphics.

#The mapping is done using the aes() function. It specifies which variables to map to the x and y axes:
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
)
#Now the x-axis is mapped to flipper_length_mm and the y-axis is mapped to body_mass_g.

#3. Layers
#To visualize the data, we need to add layers to the plot that tell ggplot2 how to display the mapped data.
#To do this, we need to add a geom layer which specifies the type of plot to create (e.g., points, lines, bars).

#The geom layer is added using the geom_*() function, such as:
#geom_point() for scatter plots, geom_line() for line plots, and geom_bar() for bar plots, geom_boxplot() for box plots, etc.

#For example, to create a scatter plot, we can add the geom_point() layer like this:
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) + 
  geom_point()

#----------------------- Customizing the plot -----------------------
#1. Adding aesthetics
#Aesthetics are visual properties of the plot, such as color, size, shape, and fill.

#To add color to the points based on the species of penguins, we simply modify the aes() function to include the color aesthetic:
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) + 
  geom_point()
#By mapping the variable 'species' to the color aesthetic, different species will be represented by a different color in the plot.

#2. Adding a new geom layer
#We can add a new geom layer to show a best fit line displaying the relationship between the 2 variables
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point() +
  geom_smooth(method = "lm") #this specifies that we want to fit a linear model (lm) to the data
#As you can see, there are now 3 best fit lines, one for each species of penguin.

#Problem: What if we want only 1 best fit line for all the species?
#When aesthetic mappings are defined in ggplot(), they’re passed down to each of the subsequent geom layers of the plot
#However, each geom function in ggplot2 can also take a mapping argument

#So, we just have to move the 'color = species' aesthetic mapping from the ggplot() function to the geom_point() function
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species)) +
  geom_smooth(method = "lm")
#This way, the color aesthetic is only applied to the points, and the best fit line is calculated for the entire dataset.

#3. Using shapes to represent data points
#Sometimes, we may want to use shapes to represent different categories in our data, in case of color blindness.

#To do this, use the 'shape' aesthetic in the aes() function:
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species, shape = species)) +
  geom_smooth(method = "lm")

#4. Adding labels and titles
#We can add a layer for labels and titles using the labs() function:
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(aes(color = species, shape = species)) +
  geom_smooth(method = "lm") +
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)", y = "Body mass (g)",
    color = "Species", shape = "Species"
  )
