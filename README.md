## Lexo Rank

This package lets you generate lexo ranks in flutter. Lexo rank ordering of items in a list
according to their alphabetical rank.

## Usecases for lexo ranks
- We use lexo ranks whenever we have use case of rearranging list items
- instead of having integer based ranking we can have String and bucket based
lexo ranks, so that rearranging list items is done in o(1) complexity.
  Drag and drop is a popular feature in applications.
  However, by implementing this functionality, you should be aware of some nuances:
  a large number of elements, recalculation of the positions every time and some additional 
  logic if you have different sections in the list.
  
You can read more about why and how to use lexo ranks here:
1. https://tmcalm.nl/blog/lexorank-jira-ranking-system-explained/
2. https://medium.com/whisperarts/lexorank-what-are-they-and-how-to-use-them-for-efficient-list-sorting-a48fc4e7849f

## Example 

1. Generate first lexo rank we use -> 
   `LexoRank rank = LexoRank.middle()`
   
2. Generate previous lexo rank ->  
   `rank.genPrev()`
   
3. Generate next rank ->
   `rank.genNext()`
   
4. Generate Middle Lexo Rank -> 
   `prevLexoRank.between(nextLexoRank)`

5. Parse strings to make LexoRank objects
   Usecase -> For example you are storing lexo ranks in Database as String, and in order to generate
   new ranks, you will need LexoRank objects, the function `LexoRank.parse(str)` which accepts a string will
   return you a `LexoRank` object
   kudos to @maelchiotti for this documentation suggestion

Please go to root -> example/lib/main.dart to look into comprehensive example.
 

