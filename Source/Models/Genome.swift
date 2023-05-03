//
//  Genome.swift
//  Biots
//
//  Created by Robert Silverman on 4/15/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import OctopusKit
import SpriteKit

struct Genome: CustomStringConvertible, Codable {
	
	var id: String = ""
	var generation: Int = 0
	
	// neural net
	var inputCount: Int = 0
	var hiddenCounts: [Int] = []
	var outputCount: Int = 0
	var weights: [[Float]] = [[]]
	var biases: [[Float]] = [[]]

	var nodeCounts: [Int] {
		var counts: [Int] = []
		counts.append(inputCount)
		counts.append(contentsOf: hiddenCounts)
		counts.append(outputCount)
		return counts
	}
	
	var weightCounts: [Int] {
		let nodeCounts = self.nodeCounts
		var counts: [Int] = [0]
		for layerIndex in 1..<nodeCounts.count {
			let count = nodeCounts[layerIndex] * nodeCounts[layerIndex - 1]
			counts.append(count)
		}
		return counts
	}
	
	var biasCounts: [Int] {
		let nodeCounts = self.nodeCounts
		var counts: [Int] = [0]
		for layerIndex in 1..<nodeCounts.count {
			let count = nodeCounts[layerIndex]
			counts.append(count)
		}
		return counts
	}
			
	// new genome
	init(inputCount: Int, hiddenCounts: [Int], outputCount: Int) {
		self.inputCount = inputCount
		self.hiddenCounts = hiddenCounts
		self.outputCount = outputCount

		id = UUID().uuidString
		generation = 0
		
		let randomized = initialWeightsAndBiases(random: true)
		weights = randomized.weights
		biases = randomized.biases
		//print("created genome:")
		//print(jsonString)
	}
	
	// new genome from parent
	init(parent: Genome, mutationRate: Float, shouldMutate: Bool = true) {
		id = UUID().uuidString
		generation = parent.generation + 1
		
		inputCount = parent.inputCount
		hiddenCounts = parent.hiddenCounts
		outputCount = parent.outputCount
		weights = parent.weights
		biases = parent.biases

		if shouldMutate {
			mutate(mutationRate: mutationRate)
		}
	}
	
	var idFormatted: String {
		return id.truncated(8, trailing: "")
	}
	
	var description: String {
		return "{id: \(idFormatted), gen: \(generation), nodes: [\(inputCount), \(hiddenCounts), \(outputCount)]}"
	}

	var jsonString: String {
		let json =
		"""
		{
			"id": "\(id)",
			"generation": \(generation),
			"inputCount": \(inputCount),
			"hiddenCounts": \(hiddenCounts),
			"outputCount": \(outputCount),
			"weights": \(weights),
			"biases": \(biases)
		}
		"""
		return json
	}
}

extension Genome {

	mutating func mutate(mutationRate: Float) {
		// mutationRate: 1...0 ==> 4...0 chances
		let weightsChances = Int.random(Int(2 + 3*mutationRate))
		// mutationRate: 1...0 ==> 1...0 chances
		let biasesChances = Int.oneChanceIn(12 - Int(2 + 6*mutationRate)) ? 1 : 0

		if weightsChances + biasesChances > 0 {
			for _ in 0..<weightsChances { mutateWeights() }
			for _ in 0..<biasesChances { mutateBiases() }
		}
	}
		
	mutating func mutateWeights() {
		let randomLayerIndex = Int.random(min: 1, max: weightCounts.count - 1)
		let randomWeightIndex = Int.random(min: 0, max: weights[randomLayerIndex].count - 1)
		weights[randomLayerIndex][randomWeightIndex] = mutateWeight(weights[randomLayerIndex][randomWeightIndex])
	}
	
	mutating func mutateBiases() {
		let randomLayerIndex = Int.random(min: 1, max: biasCounts.count - 1)
		let randomBiasIndex = Int.random(min: 0, max: biases[randomLayerIndex].count - 1)
		biases[randomLayerIndex][randomBiasIndex] = mutateWeight(biases[randomLayerIndex][randomBiasIndex])
	}
	
	func mutateWeight(_ weight: Float) -> Float {
		
		let selector = Int.random(6)
		let max = Constants.NeuralNet.maxWeightValue.cgFloat

		let minMutationRate: CGFloat = max * 0.25
		let maxMutationRate: CGFloat = max * 0.5
		
		switch selector {
		case 0: return weight / 2
		case 1: return Float((weight + weight).cgFloat.clamped(-max, max))
		case 2: return Float.random(in: -Float(max)...Float(max))
		// 50% chance
		default: return Float((CGFloat(weight) + (CGFloat.random(in: minMutationRate..<maxMutationRate) * Int.randomSign.cgFloat)).clamped(-max, max))
		}
	}
	
	func initialWeightsAndBiases(random: Bool = false, initialValue: Float = 0) -> (weights: [[Float]], biases: [[Float]]) {
		
		var randomizedWeights: [[Float]] = []
		var randomizedBiases: [[Float]] = []

		let max: Float = Constants.NeuralNet.maxWeightValue
		
		let weightCounts = self.weightCounts
		let biasCounts = self.biasCounts
		
		for weightCount in 0..<weightCounts.count {
			var randomizedLayer: [Float] = []
			for _ in 0..<weightCounts[weightCount] {
				let value = random ? Float.random(in: -max...max) : initialValue
				randomizedLayer.append(value)
			}
			randomizedWeights.append(randomizedLayer)
		}
		
		for biasCount in 0..<biasCounts.count {
			var randomizedLayer: [Float] = []
			for _ in 0..<biasCounts[biasCount] {
				let value = random ? Float.random(in: -max...max) : initialValue
				randomizedLayer.append(value)
			}
			randomizedBiases.append(randomizedLayer)
		}

		return (weights: randomizedWeights, biases: randomizedBiases)
	}
	
	func crossOverGenomes(other: Genome, mutationRate: Float) -> (Genome, Genome) {
		
		var genome1 = Genome(parent: self, mutationRate: mutationRate, shouldMutate: false)
		var genome2 = Genome(parent: other, mutationRate: mutationRate, shouldMutate: false)
		
		guard genome1.nodeCounts == genome2.nodeCounts else {
			OctopusKit.logForSimErrors.add("genome1 and genome2 do not have the same neural net structure!")
			return (self, other)
		}
		
		let flatWeights1 = genome1.weights.flatMap { $0 }
		let flatBiases1 = genome1.biases.flatMap { $0 }
		let flatWeights2 = genome2.weights.flatMap { $0 }
		let flatBiases2 = genome2.biases.flatMap { $0 }

		let crossoverPoint = Float.random(in: 0...1)
		let weightsCrossoverPoint = Int(Float(flatWeights1.count) * crossoverPoint)
		let biasesCrossoverPoint = Int(Float(flatBiases1.count) * crossoverPoint)

		OctopusKit.logForSimInfo.add("🤞🏻 crossing over genomes at points: \(weightsCrossoverPoint) and \(biasesCrossoverPoint)")
		
		let weights1Head = flatWeights1.prefix(weightsCrossoverPoint)
		let weights1Tail = flatWeights1.suffix(from: weightsCrossoverPoint)
		let weights2Head = flatWeights2.prefix(weightsCrossoverPoint)
		let weights2Tail = flatWeights2.suffix(from: weightsCrossoverPoint)

		let biases1Head = flatBiases1.prefix(biasesCrossoverPoint)
		let biases1Tail = flatBiases1.suffix(from: biasesCrossoverPoint)
		let biases2Head = flatBiases2.prefix(biasesCrossoverPoint)
		let biases2Tail = flatBiases2.suffix(from: biasesCrossoverPoint)

		let newWeights1 = Array(weights1Head + weights2Tail)
		let newBiases1 = Array(biases1Head + biases2Tail)
		let newWeights2 = Array(weights2Head + weights1Tail)
		let newBiases2 = Array(biases2Head + biases1Tail)

		genome1.weights = reconstituteLayers(layerCounts: genome1.weightCounts, flatWeights: newWeights1)
		genome1.biases = reconstituteLayers(layerCounts: genome1.biasCounts, flatWeights: newBiases1)
		genome2.weights = reconstituteLayers(layerCounts: genome2.weightCounts, flatWeights: newWeights2)
		genome2.biases = reconstituteLayers(layerCounts: genome2.biasCounts, flatWeights: newBiases2)

		return (genome1, genome2)
	}
	
	func reconstituteLayers(layerCounts: [Int], flatWeights: [Float]) -> [[Float]] {
		
		var reconstituted: [[Float]] =  []
		var workingFlatArray: [Float] = flatWeights
		
		for layerCount in layerCounts {
			if layerCount > 0 {
				reconstituted.append(Array(workingFlatArray.prefix(layerCount)))
				workingFlatArray = workingFlatArray.suffix(workingFlatArray.count - layerCount)
			}
			else {
				reconstituted.append([])
			}
		}

		return reconstituted
	}
}

extension Genome {
	static func newRandomGenome() -> Genome {
		let inputCount = Constants.Vision.eyeAngles.count * Constants.Vision.colorDepth + Senses.newInputCount
		let outputCount = Inference.outputCount
		let hiddenCounts = Constants.NeuralNet.newGenomeHiddenCounts

		return Genome(inputCount: inputCount, hiddenCounts: hiddenCounts, outputCount: outputCount)
	}
}
