#### an example for reproducting the behaviors of a CUDA GPU when overflow happens, for details please see [this blog](http://alex-x-w.github.io/2017/11/04/gpu_overflow/)
---

Filename | Description
--- | ---
1stmillion.txt | containing the 1st million prime numbers, ground truth
evaluate.py | can be used to verify results`$ python evaluate.py --gold 1stmillion.txt --test [YOUR_OUTPUT]`
genprimes.cu | the kernel, the main code to look at
