# Artificial-society

;;Randomly place the houses in the area based on input 'number-of-houses'
;;Randomly place work-places in the area based on input 'number-of-workplaces'
;;We can change the number of employees per house using 'employees-per-house'
;;
;;We can set the initial infected count using 'initial-infected'
;;We can change the spread rate using 'spread-rate'
;;
;;Currently model works for only one iteration : goto workplace and go back home.
;;
;;Total number of employees will be based on employees per house and number
;;of houses. Currently all the employees including infected and non infected
;;employees leave the houses and goto work. Then come back to the same home
;;assigned. The infection is spread when a non-infected person meets a
;;infected person. And it may depend on the spread-rate and the distance of
;;infected person with the non infected person.
