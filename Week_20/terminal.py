import numpy as np

x = np.array([[1,2],[3,4]], dtype=np.float64)
y = np.array([[5,6],[7,8]], dtype=np.float64)

# Elementwise sum; both produce the array
# [[ 6.0  8.0]
#  [10.0 12.0]]
print("Output of adding x and y with a '+' operator:",x + y)
print("Output of adding x and y using 'numpy.add':",np.add(x, y))

# Elementwise difference; both produce the array
# [[-4.0 -4.0]
#  [-4.0 -4.0]]
print("Output of subtracting x and y with a '-' operator:",x - y)
print("Output of subtracting x and y using 'numpy.subtract':",np.subtract(x, y))

# Elementwise product; both produce the array
# [[ 5.0 12.0]
#  [21.0 32.0]]
print("Output of elementwise product of x and y with a '*' operator:",x * y)
print("Output of element wise product of x and y using 'numpy.multiply':",np.multiply(x, y))

# Elementwise division; both produce the array
# [[ 0.2         0.33333333]
#  [ 0.42857143  0.5       ]]
print("Output of elementwise division x and y with a '/' operator:",x / y)
print("Output of elementwise division x and y using 'numpy.divide':",np.divide(x, y))

# Elementwise square root; produces the array
# [[ 1.          1.41421356]
#  [ 1.73205081  2.        ]]
print("Output of elementwise square root x using 'numpy.sqrt':",np.sqrt(x))