BEGIN { sum=0 }
{
  if ($5 ~ $i){
      sum+=$10
  }
}
 END {
  print sum
 }
