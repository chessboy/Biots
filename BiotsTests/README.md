#  DataMiner

### Overview
DataMiner is a tool to collect data from various sources and stitch it together to create a dataset for purposes of ML model training. This application will build a dataset from categories of qualifying medical expenses (QMEs) for use with Apple's [Create ML](https://developer.apple.com/documentation/createml) app and its [Text Classifier](https://developer.apple.com/documentation/createml/creating_a_text_classifier_model) component.

We will gather 30-50 sample titles for each QME category and use those as features for the classifier. The labels for the classifier are the category ids themselves.

With a trained model we will be able to predict the category of most given product titles. Let's build the dataset!

### Collect the data

Step 1. Create a table of **categories**, each one having an **id** and a **qualification class** in `[yes | no | maybe]`:

|   id    |   cat                    |   qual   |
|---------|--------------------------|----------|
|   1000  |   Acetaminophen          |   yes    |
|   1001  |   Acid Controller        |   yes    |
|   1006  |   Acupuncture Equipment  |   maybe  |
|   ...   |   ...                    |   ...    |
|   1491  |   Wound Seal Powder      |   yes    |
|   1492  |   Wrinkle Cream          |   no     |
|   1493  |   Zinc Supplements       |   no     |

Step 2. Convert this table to json for feeding into DataMiner. This data file will also be used in the client app during classification prediction.

`categories.json`
```json
[
   {
	  "id":1000,
	  "cat":"Acetaminophen",
	  "qual":"yes"
   },
   ...
   {
	  "id":1493,
	  "cat":"Zinc Supplements"
	  "qual":"no"
   }
]
```

Step 3. Use the [Rainforest API](https://rainforestapi.com/docs) to collect products (and associated ASIN) from Amazon.com using the category name as the search term. This can be done in the simulator app with the **Rainforest Gather** button.

```
for each product category:
	fetch search results (set of product summary) via rainforest api and record as json along with the category
```

The results will be saved to the app's Documents directory with the naming convention `XXXX.json` where `XXXX` is the category id. Each search result json file will have the following structure:

`1000.json`
```json
{
   "category":{
	  "id":"1000",
	  "qual":"yes",
	  "cat":"Acne Medicine"
   },
   "search_results":[
	  {
		 "title":"Neutrogena Oil-Free Acne Fighting Facial Cleanser with Salicylic Acid Acne Treatment Medicine, Daily Oil-Free Acne Face Wash for Acne-Prone Skin, 9.1 fl. oz, 3 pk",
		 "asin":"B001E96OU6",
		 "link":"https://www.amazon.com/dp/B001E96OU6"
	  },
	  {
		 "title":"Clean & Clear Continuous Control Benzoyl Peroxide Acne Face Wash with 10% Benzoyl Peroxide Acne Treatment, Daily Facial Cleanser with Acne Medicine to Treat and Prevent Acne, For Acne-Prone Skin, 5 oz",
		 "asin":"B002OTNVX8",
		 "link":"https://www.amazon.com/dp/B002OTNVX8"
	  },
	 ...
}
```

Typically 30-50 titles are returned for most categories.

Step 4: Get detailed information for each product from the [barcodeable.com API](https://www.barcodable.com/documentation) so we have more data to train the ML model with. This can be done with the **Barcodeable Gather** button in the app.

```
for each search result set tied to a category:
	for each product summary in that set with an asin:
		// note: the number of products per category to fetch is configurable
		fetch the product detail via barcodeable api by asin and record it along with the product summary and category
```

The results are stored in app's Documents directory with the naming convention `XXXX_BYYYYYYYYY.json` where `XXXX` is the category id and `BYYYYYYYYY` is the ASIN. Each product detail json file will have the following structure:

`2000_B00E4MPE4C.json`
```json
{
   "ean":"0070501017906",
   "category_hierarchies":[
	  "Health & Household",
	  "Vitamins & Dietary Supplements"
   ],
   "asin":"B00E4MPE4C",
   "categories":[
	  "Vitamins & Dietary Supplements"
   ],
   "title":"Neutrogena On-The-Spot Acne Treatment 0.75oz (2 Pack)",
   "new_price":14.42,
   "brand":"Neutrogena",
   "description":"(pack of 2) 007799",
   "features":[
	  "Gentle On Skin",
	  "Absorbs Quickly",
	  "Vanishing Cream Formula",
	  "Fights Acne-Causing Bacteria",
	  "2 Pieces - 0.75oz"
   ],
   "upc":"070501017906",
   "url":"https://www.amazon.com/Neutrogena-Spot-Acne-Treatment-0-75oz/dp/B00E4MPE4C"
}
```
We can specify the preferred number of products to fetch for category for using an initial `CreationProgressMemento`:

```swift
let progress = CreationProgressMemento(searchResult: searchResult, preferred: 15, maxTries: 30)
```
This memento will be passed around during the fetch cycle for each category. In the example above we're saying we'd prefer to have 15 results, but only want to try 30 fetches maximum. In some cases we'll get 15 easily, in other cases we may only get 5 or 10. barcodeable.com has 250M products in its database, but not all of them have ASINs and not every ASIN'ed product is there. We can play with the numbers to maximize results and optimize network calls. 

A manifest will be generated which records only the product ASINs that were fetched and saved for each category:

`manifest.json`
```json
[
   {
	  "cat":"1000",
	  "asins":[
		 "B00E4MPE4C",
		 "B01DDIRE2W",
		 ...		 
	  ]
   },
   ...
   {
	  "cat":"1001",
	  "asins":[
		 "B001AZTD52",
		 "B00GMP4QNO",
		 ...
	  ]
   },
```

We now have a file-based, json database stored locally to create a dataset.

### Stitch the data into a dataset

Step 5. Generate a large dataset to be used to train the a text classifier ML model. This can be done with the **Create Dataset** button in the app.

```
for each row:
	add a 3 records of: category info + lemmatized title info + source of title info
```
The title info is made up of:
	1. Amazon product title (amz)
	2. Barcodeable product title (bar)
	3. Barcodeable category + category hierarchies (cat)

`dataset.json`
```json
[
   {
	  "cat":"Acne Medicine",
	  "label":"1000",
	  "asin":"B001E96OU6",
	  "text":"neutrogena oil free acne wash 9.1 ounce pack 3",
	  "src":"bar",
	  "qual":"yes"
   },
   {
	  "cat":"Acne Medicine",
	  "label":"1000",
	  "asin":"B001E96OU6",
	  "text":"neutrogena oil free acne fight facial cleanser salicylic acid acne treatment medicine daily oil free acne face wash acne prone skin 9.1 fl. ounce 3 pk",
	  "src":"amz",
	  "qual":"yes"
   },
   {
	  "cat":"Acne Medicine",
	  "label":"1000",
	  "asin":"B001E96OU6",
	  "text":"wash beauty personal care skin care face cleanser wash",
	  "src":"cat",
	  "qual":"yes"
   },
   ...
```
The above json snippet shows 3 samples for the label `1000` that were gathered from a single product ASIN. We would typically use 10-15 products for the same label, giving us 30-45 samples per label. We can always scale up if accuracy is not high enough.

That's it for dataset creation. Next we would train the model using `dataset.json`. Note only `label` and `text` are used in the classifier. Once the model is trained it can be imported into a client app and used like this:

```swift
	let predictedCategory = productClassiferModel.prediction(text: productTitle.lemmatized)
	return categories.filter { $0.id == predictedCategory.label }.first
```
