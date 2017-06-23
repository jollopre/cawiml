public Operand evaluate() throws OperandException,RpnException{
		LOCK = true;
		if(expression == null){ reset(); throw new RpnException("RPN expression is NULL");}
		stack.clear();
		Token first,second;
		for(int i=0;i<expression.size();i++){
			if(expression.get(i) instanceof Variable){
				Variable var = (Variable)expression.get(i);
				stack.add(var.getOperand());
			}
			else if(expression.get(i) instanceof Operand){
				stack.push(expression.get(i));
			}
			else if(expression.get(i) instanceof Operator){
				Operator o = (Operator)expression.get(i);
				if(o.isBinary()){	//BINARY OPERATION
					if(stack.isEmpty()){ reset(); throw new RpnException("Empty stack trying to retrieve second operand for binary operation");}
					second = stack.pop();
					if(stack.isEmpty()){ reset(); throw new RpnException("Empty stack trying to retrieve first operand for binary operation");}
					first = stack.pop();
					result = ((Operand)first).resolve((Operand) second, o);
					stack.add(result);
				}
				else{	//UNARY OPERATION
					if(stack.isEmpty()){ reset(); throw new RpnException("Empty stack trying to retrieve the operand for unary operation");}
					first = stack.pop();
					result = ((Operand)first).resolve(o);
					stack.add(result);
				}
			}
			else{
				reset(); throw new RpnException("Unknown token processing the RPN expression");
			}
		}
		if(stack.isEmpty()){reset(); throw new RpnException("Not enough arguments in the RPN expression");}
		first = stack.pop();
		if(!stack.isEmpty()){reset(); throw new RpnException("Malformed RPN expression");}
		LOCK=false;
		result=(Operand)first;
		return result;
	}