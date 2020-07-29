# -*- coding: utf-8 -*-
# Dependencies
import tensorflow as tf
import pandas as pd
import numpy as np


def print_c_array(python_array):

    return str(python_array)

    string = "{ "

    for i in range(len(python_array)):
        if isinstance(python_array[i], np.ndarray):
            for j in range(len(python_array[i])):
                string += str(python_array[i][j])
                if(j != len(python_array[i]) - 1):
                    string += ", "
        else:
            string += str(python_array[i])
        if(i != len(python_array) - 1):
            string += ", "

    string += "}"

    return string


# Make results reproducible
seed = 1234
np.random.seed(seed)
tf.set_random_seed(seed)

# Loading the dataset
dataset = pd.read_csv('Iris_Dataset.csv')
dataset = pd.get_dummies(dataset, columns=['Species'])  #  One Hot Encoding
values = list(dataset.columns.values)

y = dataset[values[-3:]]
y = np.array(y, dtype='float32')
X = dataset[values[1:-3]]
X = np.array(X, dtype='float32')

# # Shuffle Data
# indices = np.random.choice(len(X), len(X), replace=False)
# X_values = X[indices]
# y_values = y[indices]

X_values = X
y_values = y

# Creating a Train and a Test Dataset
test_size = 10
X_test = X_values
X_train = X_values
y_test = y_values
y_train = y_values

# Session
sess = tf.Session()

# Interval / Epochs
interval = 50
epoch = 500

# Initialize placeholders
X_data = tf.placeholder(shape=[None, 4], dtype=tf.float32)
y_target = tf.placeholder(shape=[None, 3], dtype=tf.float32)

#  Input neurons : 4
# Hidden neurons : 8
# Output neurons : 3
hidden_layer_nodes = 8

# Create variables for Neural Network layers
# Inputs -> Hidden Layer
w1 = tf.Variable(tf.random_normal(shape=[4, hidden_layer_nodes]))
b1 = tf.Variable(tf.random_normal(shape=[hidden_layer_nodes]))   # First Bias
# Hidden layer -> Outputs
w2 = tf.Variable(tf.random_normal(shape=[hidden_layer_nodes, 3]))
b2 = tf.Variable(tf.random_normal(shape=[3]))   # Second Bias

# Operations
hidden_output = tf.nn.relu(tf.add(tf.matmul(X_data, w1), b1))
final_output = tf.nn.softmax(tf.add(tf.matmul(hidden_output, w2), b2))

# Cost Function
loss = tf.reduce_mean(-tf.reduce_sum(y_target * tf.log(final_output), axis=0))

# Optimizer
optimizer = tf.train.GradientDescentOptimizer(
    learning_rate=0.001).minimize(loss)

# Initialize variables
init = tf.global_variables_initializer()
sess.run(init)

# Training
print('Training the model...')
for i in range(1, (epoch + 1)):
    sess.run(optimizer, feed_dict={X_data: X_train, y_target: y_train})
    if i % interval == 0:
        print('Epoch', i, '|', 'Loss:', sess.run(
            loss, feed_dict={X_data: X_train, y_target: y_train}))

temp = sess.run(w1)


print("weight1: " + print_c_array(sess.run(w1)))
print("bias1: " + print_c_array(sess.run(b1)))

print("weight2: " + print_c_array(sess.run(w2)))
print("bias2: " + print_c_array(sess.run(b2)))
#  Prediction
print()
for i in range(len(X_test)):
    print(sess.run(final_output, feed_dict={X_data: [X_test[i]]}))
