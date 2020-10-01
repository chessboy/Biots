//
//  NeuralNetComponent.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/12/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class NeuralNetComponent: OKComponent, OKUpdatableComponent {
		
	var id: String = ""
	var neuralNet: NeuralNet!
	var neuralNetBlewUp = false
	var genome: Genome

	init(genome: Genome) {
		
		self.id = ""
		self.genome = genome
		
		do {
			let structure = try NeuralNet.Structure(nodes: genome.nodeCounts, hiddenActivation: .hyperbolicTangent, outputActivation: .hyperbolicTangent, batchSize: 1, learningRate: 0.1, momentum: 0.5)
			
			let neuralNet = try NeuralNet(structure: structure)
			self.neuralNet = neuralNet
			
		} catch let error {
			print("\(error.localizedDescription)")
		}
		
		super.init()
	}
	
	public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func didAddToEntity() {
		do {
			try neuralNet.setWeights(genome.weights)
			try neuralNet.setBiases(genome.biases)
		} catch let error {
			print("\(error.localizedDescription)")
		}
	}
		
	func infer(_ inputs: [Float]) -> [Float] {
		var outputs = [Float]()
		
		do {
			outputs = try neuralNet.infer(inputs)
			
			let min: Float = -1
			let max: Float = 1
			
			var outputsSafe = true
			for output in outputs {
				if output < min || output > max {
					outputsSafe = false
					break
				}
			}
						
			if !outputsSafe {
				OctopusKit.logForWarnings.add("-•- outputs out of range for \(id) [\(min.formattedTo2Places), \(max.formattedTo2Places)]: \(outputs)")
				neuralNetBlewUp = true
				for i in 0..<outputs.count {
					outputs[i] = 0
				}
			}
			
			return outputs
			
		} catch let error {
			print("\(error)")
			return Array(repeating: Float.zero, count: genome.outputCount)
		}
	}
}

