from promptflow.core import Prompty

# load prompty as a flow
f = Prompty.load(source="./src/chat.prompty")

# execute the flow as function
result = f(question="What is the capital of France?", documents=[])
print(result)
