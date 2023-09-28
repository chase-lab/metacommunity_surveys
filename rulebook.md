The Rulebook
=================

# Splitting
- Do we keep absences when they are given? No
- Do we keep empty sites? (alston_2021a, alston_2021b) Yes. This has to be described in data set comments and in the manual. NA species can mean empty trap or a problem: double check.
- What if the data is incomplete: missing site name or missing species name or missing year. If there is no way to figure it out, throw away and document.
- Do we keep duplicated rows? toss it
- Do we keep duplicated observations of species in a sample? Remove whole sample and document.
- Do we keep "bare ground" cover? exclude it but keep unknown sponge
- Do we keep cover? alston_2021c. Keep it. type = cover, unit = percentage
 
- What do we do with recaptured individuals? We keep them (# How are individuals that are captured twice in the same trap or twice in the same grid during the same campaign counted? They are kept because maybe this happens in other sampling designs without it being recorded)

- Do we pool lifestages? size classes?. pool them but write down that it is available in the raw raw data.
- If the data had individual level data, do we pool them? alston_2021b. Yes and write down that it is available in the raw data.
- If, for example in a bird study, bird abundances are reported with distances: one row is Pica pica heard at 5 meters and next row is Pica pica heard at 30 meters: we pool them and add up the abundances? Yes and write down that it is available in the raw data.
 
- Do we need the effort column? No because it is expected to be constant.
 
- If there is no standardisation at all in the current script, we still create 2 files, 1 raw, 1 standardised even if they are identical. Yes
- If the authors say: Euphorbia spp. were present but not recorded in 2009. For standardised, we exclude all Euphorbia. And for Raw data? (Alston_2021a). Keep it but write a warning.
- If the authors say: In some sections in some years, two rows for the same species were inadvertently recorded with different numbers of trees. We recommend that data users average these entries to account for these data errors. -> we average the abundances of the repeated rows (alston_2021a). For the raw data: we process the data as in standardised.
- if already standardisation of abundance is given in column of raw dataframe, keep that one as value or take the raw abundance data? Case by case.
 
- Do we add grain and extent calculations in the raw data too? If yes and if raw data has several samplings a year, are gamma_sum_grains and gamma_bounding_box computed per day?
Gamma columns should not be in the raw data. regional should not either. local could be renamed sampleDesc cf how they call it in BioTIME

Names for raw and standardised date sets:
   processed raw & processed standardised
