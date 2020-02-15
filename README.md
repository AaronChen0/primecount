# primecount

Prime counting of sublinear complexity in Common Lisp.
<pre>Time  Complexity: O(x<sup>3/4</sup>)  
Space Complexity: O(x<sup>1/2</sup>)</pre>

## Benchmarks
<table>
  <tr align="center">
    <td><b>x</b></td>
    <td><b>Prime Count</b></td>
    <td><b>SBCL</b></td>
    <td><b>CCL</b></td>
    <td><b>CLISP</b></td>
  </tr>
  <tr align="center">
    <td><b>10<sup>9</sup></b></td>
    <td><b>50847534</b></td>
    <td><b>0.06s</b></td>
    <td><b>0.19s</b></td>
    <td><b>1.64s</b></td>
  </tr>
  <tr align="center">
    <td><b>10<sup>10</sup></b></td>
    <td><b>455052511</b></td>
    <td><b>0.29s</b></td>
    <td><b>0.97s</b></td>
    <td><b>8.47s</b></td>
  </tr>
  <tr align="center">
    <td><b>10<sup>11</sup></b></td>
    <td><b>4118054813</b></td>
    <td><b>1.47s</b></td>
    <td><b>5.03s</b></td>
    <td><b>43.26s</b></td>
  </tr>
  <tr align="center">
    <td><b>10<sup>12</sup></b></td>
    <td><b>37607912018</b></td>
    <td><b>7.61s</b></td>
    <td><b>25.8s</b></td>
    <td><b>222.36s</b></td>
  </tr>
</table>

The benchmarks were made on my 1.9 GHz old laptop.  
It can be seen that the gaps between different lisp systems  
are quite large.

## Usage Examples

``` common-lisp
;; count primes <= 10^11
(primecount:prime-count (expt 10 11))

;; sum primes <= 10^11
(primecount:prime-sum (expt 10 11))

;; count primes of the forms 4m+1 and 4m+3 <= 10^11
;; (values 4m+1 4m+3)
(primecount:prime-count-mod4 (expt 10 11))

;; test if the results of prime-count match those of 
;; prime-count-mod4
(defun test (range times)
  (loop repeat times
     for i = (random range)
     do (multiple-value-bind (n1 n3) 
            (primecount:prime-count-mod4 i)
          (assert (= (primecount:prime-count i)
                     (+ n1 n3 1))))))
(test 1000000000 10)
```

## Installation

``` bash
cd ~/my/quicklisp/local-projects/
git clone https://github.com/AaronChen0/primecount.git
```

``` common-lisp
(ql:quickload "primecount")
```

## Algorithm
The origin idea came from Lucy_Hedgehog from projecteuler.  
It uses an optimzed sieving method as shown in
[sympy](https://docs.sympy.org/latest/modules/ntheory.html#sympy.ntheory.generate.primepi).

## Todo
Implement more efficient algorithms in pure Common Lisp.  
A good reference is https://github.com/kimwalisch/primecount.
