# Understanding peace through the world news (step-by-step methodology)
# Table of contents
# Abstract 
Peace is a principal dimension of well-being and is the way out of inequity and violence. Thus, its measurement has drawn the attention of researchers, policymakers, and peacekeepers. During the last years, novel digital data streams have drastically changed the research in this field. The current study exploits information extracted from a new digital database called Global Data on Events, Location, and Tone (GDELT) to capture peace through the Global Peace Index (GPI). Applying predictive machine learning models, we demonstrate that news media attention from GDELT can be used as a proxy for measuring GPI at a monthly level. Additionally, we use techniques from explainable AI to obtain the most important variables that drive the predictions. 
This analysis highlights each country's profile and provides explanations for the predictions, and particularly for the errors and the events that drive these errors. We believe that digital data exploited by researchers, policymakers, and peacekeepers, with data science tools as powerful as machine learning, could contribute to maximizing the societal benefits and minimizing the risks to peace.

## Data preprocessing

### GDELT data
For GPI prediction, we derive several variables from GDELT, corresponding to the total number of events (No. events) of each GDELT category at a country and monthly level. On average, the number of variables per country is 87, varying from 25 to 141. We use the BigQuery data manipulation language in 
the Google Cloud Platform to extract the GDELT variables. You can find the query for the extraction of GDELT variables below:

`SELECT ActionGeo_CountryCode,MonthYear,EventBaseCode, <br/>
COUNT(EventBaseCode) AS No_events, <br/>
FROM 'gdelt-bq.full.events' 
WHERE(MonthYear>200802)AND(MonthYear<202010)
AND(ActionGeo_CountryCode<>'null')
GROUP BY ActionGeo_CountryCode,MonthYear,EventBaseCode
ORDER BY ActionGeo_CountryCode,MonthYear,EventBaseCode`

The extracted data can be found in the folder named `gdelt_data_200803_202009`.

### GPI data
GPI ranks 163 independent states and territories according to their level of peace, and it was created by the Institute for Economics & Peace (IEP). 
GPI data are available from 2008 until 2020 at a yearly level. We download the yearly GPI data from the IEP site. These data can be found in the folder named `gpi_all_countries.csv`. Next, we use the `Fips10_4.csv` to match the countries with the FIPS country codes used by the GDELT database. In addition, for this study, we increase GPI frequency from yearly to monthly data using linear interpolation. Every yearly GPI value is assigned to March of the corresponding year since most of the annual GPI indicators are measured until this month. We upsample the yearly GPI score to monthly GPI score for each country, 
using the code named `Upsampling_GPI_score_for_all_countries.ipynb`.

## Machine learning
We merge GDELT and GPI data at a country level, and we prepare the data for machine learning, using the code named `Preparation_gpi_gdelt_files_for_machine_learning.ipynb`. 

We use 5 different algorithms for the machine learning of our models, i.e.,
1. Elasticnet (the R code and the packages used can be found in `Elasticnet_predictions.R`),
2. Decision Tree (the python code and the packages used can be found in `Decision_tree_predictions.ipynb`),
3. Random Forest (the python code and the packages used can be found in `Random_forest_predictions.ipynb`),
4. Extreme Gradient Boosting (XGBoost) (the python code and the packages used can be found in `XGboost_predictions.ipynb`), and
5. Support Vector Regressor (SVR) (the R code and the packages used can be found in `SVR_predictions.R`).


We repeat this code twice in order to create our data: the folders `all_variables_and_GPI_monthly_all_countries` and `all_variables_200803_202009` contain
the data prepared for machine learning and future prediction respectively.
data at a country level, and we prepare the dataframes for machine learning, using the code named `Preparation_gpi_gdelt_files_for_machine_learning.ipynb`. We repeat this code twice in order to create our data: the folders `all_variables_and_GPI_monthly_all_countries` and `all_variables_200803_202009` contain
the data prepared for machine learning and future prediction respectively.  

# SHAP methodology
To understand the variables that contribute to the measurement of peacefulness, and to explain the behaviour of the models we conduct four case studies, and
we apply the SHAP methodology:
1. Saudi Arabia case study (the python code and the packages used can be found in `Shap_XGboost_training_SA.ipynb`),
2. Yemen case study (the python code and the packages used can be found in `Shap_XGboost_training_YM.ipynb`),
3. United States case study (the python code and the packages used can be found in `Shap_XGboost_future_prediction_US.ipynb`), and
4. United Kingdom case study (the python code and the packages used can be found in `Shap_XGboost_future_prediction_UK.ipynb`).
