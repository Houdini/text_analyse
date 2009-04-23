import pylab, sys

f = open(sys.argv[1], 'r')
data = map(lambda x: float(x.split()[1]), f.readlines())
print data
f.close()
time = [i+1 for i in range(len(data))]

pylab.plot(time, data)
pylab.show()