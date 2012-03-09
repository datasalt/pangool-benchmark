/**
 * Copyright [2012] [Datasalt Systems S.L.]
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.datasalt.pangool.benchmark.secondarysort;

import java.util.Properties;

import cascading.flow.Flow;
import cascading.flow.FlowConnector;
import cascading.flow.FlowProcess;
import cascading.operation.BaseOperation;
import cascading.operation.Function;
import cascading.operation.FunctionCall;
import cascading.operation.Operation;
import cascading.operation.aggregator.Sum;
import cascading.pipe.Each;
import cascading.pipe.Every;
import cascading.pipe.GroupBy;
import cascading.pipe.Pipe;
import cascading.scheme.Scheme;
import cascading.scheme.TextLine;
import cascading.tap.Hfs;
import cascading.tap.SinkMode;
import cascading.tap.Tap;
import cascading.tuple.Fields;
import cascading.tuple.Tuple;
import cascading.tuple.TupleEntry;

/**
 * Code for solving a secondary sort problem with Cascading.
 * <p>
 * The secondary sort problem is: We have a file with sales registers: {departmentId nameId timestamp saleValue}. We
 * want to obtain meaningful statistics grouping by all people who perform sales (departmentId+nameId). We want to
 * obtain total sales value for certain periods of time, therefore we need to registers in each group to come sorted by
 * "timestamp".
 */
public class CascadingSecondarySort {

	@SuppressWarnings({ "unchecked", "rawtypes", "serial" })
	public static class ParseInput extends BaseOperation implements Function {

		public ParseInput() {
			super(Operation.ANY, new Fields("intField", "strField", "longField", "doubleField"));
		}
		
    @Override
    public void operate(FlowProcess flowProcess, FunctionCall functionCall) {
    	TupleEntry entry = functionCall.getArguments();
			// Output Tuple
			Tuple tuple = (Tuple) functionCall.getContext();
			String line = (String) entry.get("line");
			String[] fields = line.split("\t");

			if(tuple == null) {
				// Create cached Tuple
				tuple = new Tuple();
				functionCall.setContext(tuple);
				tuple.add(Integer.parseInt(fields[0]));
				tuple.add(fields[1]);
				tuple.add(Long.parseLong(fields[2]));
				tuple.add(Double.parseDouble(fields[3]));
			} else {
				tuple.set(0, Integer.parseInt(fields[0]));
				tuple.set(1, fields[1]);
				tuple.set(2, Long.parseLong(fields[2]));
				tuple.set(3, Double.parseDouble(fields[3]));
			}
			
			functionCall.getOutputCollector().add(tuple);
    }
	}
	
	public final static void main(String[] args) {

		String inputPath = args[0];
		String outputPath = args[1];

		// Define source and sink Taps.
		Scheme sourceScheme = new TextLine(new Fields("line"));
		Tap source = new Hfs(sourceScheme, inputPath);

		Scheme sinkScheme = new TextLine(new Fields("strField", "total"));
		Tap sink = new Hfs(sinkScheme, outputPath, SinkMode.REPLACE);

		// the 'head' of the pipe assembly
		Pipe assembly = new Pipe("wordcount");
		
		assembly = new Each(assembly, new Fields("line"), new ParseInput());

		assembly = new GroupBy(assembly, new Fields("intField", "strField"), new Fields("longField"));
		assembly = new Every(assembly, new Fields("doubleField"), new Sum(new Fields("total")));

		// initialize app properties, tell Hadoop which jar file to use
		Properties properties = new Properties();
		FlowConnector.setApplicationJarClass(properties, CascadingSecondarySort.class);

		// plan a new Flow from the assembly using the source and sink Taps
		// with the above properties
		FlowConnector flowConnector = new FlowConnector(properties);
		Flow flow = flowConnector.connect("secondarySort", source, sink, assembly);

		// execute the flow, block until complete
		flow.complete();
	}
}