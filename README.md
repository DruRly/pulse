##1. Bundle
<pre>
git clone ...
cd pulse
bundle
</pre>

##2. Add API Key

###Create `config/wtp.yml`
  <pre>api_key: "your api key"</pre>


##3. Setup Database

<br/>
<pre>
#Create Db
rake db:migrate

#Open Console
rails console

#Pull petitions and issues from API
Petition.pull_all

#Create mock signatures
Signature.create_mocks(180000)
</pre>


##4. Start Server

<pre>rails server</pre>


##TODO
###Seed database with real signatures
*The WTP team mentioned that a databse dump will be available soon. This could be used to seed the database. Cron jobs can then be used to pull new data on a regular basis.*
###Enable Filtering
*Filtering params are being generated. The controller use these params to filter petitions by issue.*
###Add days left before 30-day deadline
*Use the petition creation date to determine how long a petition has left to reach the threshold. Display these values under "Near Threshold"*


