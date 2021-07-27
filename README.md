# Understanding peacefulness through the world news (step-by-step methodology)
## GPI data
- We get the yearly GPI data, which are available from the official sources, for all countries from 2008 to 2020. These data can be found in the folder named `gpi_all_countries.csv`.
- Next, we use the `Fips10_4.csv` to match the countries with the FIPS country codes used by the GDELT database. 
- In addition, we upsample the yearly GPI score to monthly GPI score for each country, using the code named `Upsampling_GPI_score_for_all_countries.ipynb`.

## GDELT data
- We use the Google BigQuery to download the GDELT data, at a country and monthly level from March 2008 to September 2020. 
The data can be found in the folder named `gdelt_data_200803_202009`.
- We merge GPI and GDELT data at a country level, and we prepare the dataframes for machine learning, using the code named `Preparation_gpi_gdelt_files_for_machine_learning.ipynb`.

## Machine learning
We use 5 different algorithms for the machine learning of our models, i.e.,
1. Elasticnet (the R code and the packages used can be found in `Elasticnet_predictions.R`),
2. Decision Tree (the python code and the packages used can be found in `Decision_tree_predictions.ipynb`),
3. Random Forest (the python code and the packages used can be found in `Random_forest_predictions.ipynb`),
4. Extreme Gradient Boosting (XGBoost) (the python code and the packages used can be found in `XGboost_predictions.ipynb`), and
5. Support Vector Regressor (SVR) (the R code and the packages used can be found in `SVR_predictions.R`).

# SHAP methodology
To understand the variables that contribute to the measurement of peacefulness, and to explain the behaviour of the models we conduct four case studies, and
we apply the SHAP methodology:
1. Saudi Arabia case study (the python code and the packages used can be found in `Shap_XGboost_training_SA.ipynb`),
2. Yemen case study (the python code and the packages used can be found in `Shap_XGboost_training_YM.ipynb`),
3. United States case study (the python code and the packages used can be found in `Shap_XGboost_future_prediction_US.ipynb`), and
4. United Kingdom case study (the python code and the packages used can be found in `Shap_XGboost_future_prediction_UK.ipynb`).
