# Hotel-Pricing-Dynamics-Analysis

This repository contains an analysis of hotel pricing in relation to their distance from the city center for Rome. The study leverages multiple statistical models to uncover trends, address outliers, and provide actionable insights into pricing dynamics. Below, you'll find a detailed overview of the project, methodology, and insights.

---

## Introduction
This project examines how the prices of hotels in Rome vary with their distance from the city center. It uses data preprocessing, visualisation, and statistical modeling techniques to identify trends and anomalies, with the ultimate goal of recommending the best value-for-money hotels for travelers.

---

### Dataset Details
The dataset includes **149,966 entries** spanning multiple cities and years, specifically **2017–2018**. Key columns include:
- **`price`**: The price of booking a hotel room (int).
- **`center1distance` / `center2distance`**: Distance from city centers (string, e.g., "3.1 miles").
- **`starrating`**: Star rating of hotels, ranging from 1 to 5 stars.
- **`guestreviewsrating`**: Guest review ratings in a mixed format (e.g., "4.3 /5").
- **`offer_cat`**: Categories of promotional offers (e.g., "15-50% offer").
- **`scarce_room`**: Binary indicator for room availability (0 = plenty, 1 = scarce).
- **`holiday`**: Indicates whether a booking date falls on a holiday.


### Steps
1. Filtered data for hotels in Rome for November 2017, focusing on weekdays.
2. Addressed outliers by excluding extreme values based on price and distance.
3. Applied **log transformations** to normalise data distributions.
4. Used visualisations (such as histograms, scatterplots) to identify relationships.

---

## Analysis Overview
The analysis explores:
1. **Data Distribution**:
   - Right-skewed distributions for price and distance.
   - Clear clustering near the city center.
2. **Outlier Handling**:
   - Excluded hotels with distances > 10 miles.
   - Removed prices > $500 for better analysis of mid-range options.
3. **Relationship between Price and Distance**:
   - Visualised using scatterplots and **regression lines** (utilising log-transformations).

---

## Key Findings (economic analysis)
- **Distance and Pricing Relationship**: Prices decrease with increasing distance but plateau beyond 2 miles.
- **Best Deals**: Identified top 5 underpriced hotels offering significant value near the city center.
- **Worst Deals**: Highlighted overpriced hotels located farther away yet charging higher rates.

---

## Models and Results
The study compared three models:
1. **Linear Regression**: Basic trend analysis, limited flexibility.
2. **Log-Log Model**: Enhanced linearity and interpretability with transformations.
3. **Piecewise Linear Spline (Best Model)**:
   - Best fit with a knot at 2 miles.
   - R-squared: 0.237, explaining the most variation in pricing trends.
4. **Residual Analysis**:
    - Identified top and bottom hotel deals.
    - Created visualisations marking underpriced (green) and overpriced (red) hotels.

---

## Conclusion
- Proximity to the City Center: A significant factor influencing hotel prices, with prices dropping sharply within 2 miles of the city center and stabilising beyond that.
- Value for Money: Hotels farther from the center often charge disproportionately high rates, offering less value for money.
- Model Effectiveness: The piecewise spline model captures the key trends effectively, though it leaves substantial variation unexplained. The R-squared value of 0.237 highlights the model’s explanatory power but also suggests the need for additional predictors to improve accuracy.

