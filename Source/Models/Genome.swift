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

enum Species: Int, Codable, CaseIterable, CustomStringConvertible {
	case herbivore = 0
	case omnivore

	var description: String {
		return self == .omnivore ? "omnivore" : "herbivore"
	}
	
	var icon: String {
		return self == .omnivore ? "🦊" : "🐰"
	}
}

struct Genome: CustomStringConvertible, Codable {
	
	var id: String = ""
	var generation: Int = 0
	var species: Species = .herbivore
	var isOmnivore: Bool { return species == .omnivore }
	var isHerbivore: Bool { return species == .herbivore }
	
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
	init(species: Species = .herbivore, inputCount: Int, hiddenCounts: [Int], outputCount: Int) {
		self.species = species
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
	init(parent: Genome, mutationRate: Float) {
		id = UUID().uuidString
		generation = parent.generation + 1
		species = parent.species
		
		inputCount = parent.inputCount
		hiddenCounts = parent.hiddenCounts
		outputCount = parent.outputCount
		weights = parent.weights
		biases = parent.biases

		mutate(mutationRate: mutationRate)
	}
	
	var idFormatted: String {
		return id.truncated(8, trailing: "")
	}
	
	var description: String {
		return "{id: \(idFormatted), gen: \(generation), species: \(species.description), nodes: [\(inputCount), \(hiddenCounts), \(outputCount)]}"
	}

	var jsonString: String {
		let json =
		"""
		{
			"id": "\(id)",
			"generation": \(generation),
			"species": \(species),
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
		// mutationRate: 1...0 ==> 4...2 chances
		let weightsChances = Int.random(Int(2 + 2*mutationRate))
		let biasesChances = Bool.random() ? 0 : 1
		
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
}

extension Genome {
	static func newRandomGenome(species: Species? = nil) -> Genome {
		let inputCount = Constants.Vision.eyeAngles.count * Constants.Vision.colorDepth + Senses.newInputCount
		let outputCount = Inference.outputCount
		let hiddenCounts = Constants.NeuralNet.newGenomeHiddenCounts

		let specifiedSpecies = species ?? Species.allCases.randomElement() ?? .herbivore
		return Genome(species: specifiedSpecies, inputCount: inputCount, hiddenCounts: hiddenCounts, outputCount: outputCount)
	}
}
