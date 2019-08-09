library(testit)

assert('These numbers are equal', {

  (all.equal(4, timesTwo(2)))

  (all.equal(c(4, 8), timesTwo(c(2, 4))))

})

