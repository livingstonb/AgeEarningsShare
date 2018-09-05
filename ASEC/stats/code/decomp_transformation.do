#delimit;

cap drop counterfactual_share;
gen num_terms = popsharejkt*mearnjkt;
bysort year agecat: egen numerator = sum(num_terms);
replace numerator = popsharejt*numerator;
bysort year ${adjustvar}: egen denominator = sum(numerator);
gen counterfactual_share = numerator/denominator;
drop numerator denominator num_terms mearnjkt temp_terms popsharejt
	popsharejkt mearnjkt;
