//
//  BiotsTests.swift
//  BiotsTests
//
//  Created by Robert Silverman on 4/11/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import XCTest
@testable import Biots
@testable import OctopusKit

import CoreGraphics
import GameplayKit
import simd

class BiotsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	func testConfigParam() throws {
		let gens = [0, 10, 50, 75, 100, 200, 250]
		let generationThreshold = 200
		let params = [
			ConfigParam(start: 10, end: 20),
			ConfigParam(start: 30, end: 20),
			ConfigParam(start: 0.1, end: 0.1),
			ConfigParam(start: 0.0004, end: 0.0006),
		]
		
		for param in params {
			print(param.description)
			for gen in gens {
				print("gen: \(gen), value: \(param.valueForGeneration(gen, generationThreshold: generationThreshold))")
			}
			print()
		}
		
		let intParam = ConfigParam(start: 4, end: 2)
		print("Int test: \(intParam.description)")
		for gen in gens {
			print("gen: \(gen), value: \(Int(intParam.valueForGeneration(gen, generationThreshold: generationThreshold)))")
		}

	}
	
	func testNeuralNet() throws {
        do {
			let structure = try NeuralNet.Structure(nodes: [3, 1], hiddenActivation: .sigmoid, outputActivation: .sigmoid, batchSize: 1, learningRate: 0.1, momentum: 0.5)

            let neuralNet = try NeuralNet(structure: structure)

			// a || b (ignore c)
			let trainInputs: [[Float]] = [[0, 0, 1], [1, 1, 1], [1, 0, 1], [0, 1, 1]]
			let trainLabels: [[Float]] = [[0], [1], [1], [1]]
			let validationInputs: [[Float]] = [[1, 1, 0], [1, 0, 0], [0, 1, 0], [0, 0, 0]]
			let validationLabels: [[Float]] = [[1], [1], [1], [0]]

			let dataSet = try NeuralNet.Dataset(trainInputs: trainInputs, trainLabels: trainLabels, validationInputs: validationInputs, validationLabels: validationLabels)

			let result = try neuralNet.train(dataSet, maxEpochs: 100000, errorThreshold: 0.03, errorFunction: .crossEntropy, epochCallback: { epoch, error in

				if epoch % 1000 == 0 {
					print("epoch: \(epoch), error: \(error)")
				}

				return true
			})

			print("result: \(result)")
			for test in trainInputs + validationInputs {
				let outputs = try neuralNet.infer(test)
				print("\(test): \(outputs[0])")
			}
			
			print(neuralNet.allWeights())
			print(neuralNet.allBiases())

        } catch let error {
			XCTFail(error.localizedDescription)
        }
	}
	
	func testOutputs() throws {
		
		let genome = Genome(species: .herbivore, inputCount: 8, hiddenCounts: [4], outputCount: 2)
		
        do {
			
			var nodes: [Int] = []
			nodes.append(genome.inputCount)
			nodes.append(contentsOf: genome.hiddenCounts)
			nodes.append(genome.outputCount)

			let structure = try NeuralNet.Structure(nodes: nodes, hiddenActivation: .hyperbolicTangent, outputActivation: .hyperbolicTangent, batchSize: 1, learningRate: 0.1, momentum: 0.1)
			let neuralNet = try NeuralNet(structure: structure)
			try neuralNet.setWeights(genome.weights)
			try neuralNet.setBiases(genome.biases)

			for _ in 1...100 {
				var inputs: [Float] = []
				for _ in 1...genome.inputCount {
					inputs.append(Float.random(in: 0...1))
				}
				let outputs = try neuralNet.infer(inputs)
				print("inputs: \(inputs.map({Float($0.formattedTo2Places)!})), outputs: \(outputs.map({Float($0.formattedTo2Places)!})), sigmoid: \(outputs.map({Float($0.sigmoid.formattedTo2Places)!})), boolean: \(outputs.map({$0.sigmoidBool}))")
			}
			
        } catch let error {
			XCTFail(error.localizedDescription)
        }
	}
	
	func testCrossoverIndex() throws {
		
		let genome = Genome(species: .herbivore, inputCount: 30, hiddenCounts: [14, 8], outputCount: 8)

		let flatWeights = genome.weights.flatMap { $0 }
		let flatBiases = genome.biases.flatMap { $0 }
		
		//let crossoverPoint = Float.random(in: 0...1)
		print()
		for crossoverPoint: Float in [0.0, 0.1, 0.2, 0.4, 0.5, 0.6, 0.8, 0.9, 1] {
			
			let weightsCrossoverPoint = Int(Float(flatWeights.count) * crossoverPoint).clamped(1, flatWeights.count-1)
			let biasesCrossoverPoint = Int(Float(flatBiases.count) * crossoverPoint).clamped(1, flatBiases.count-1)
			print("crossoverPoints: \(weightsCrossoverPoint)/\(flatWeights.count), \(biasesCrossoverPoint)/\(flatBiases.count)")

			let weights1 = flatWeights.prefix(weightsCrossoverPoint)
			let weights2 = flatWeights.suffix(from: weightsCrossoverPoint)
			let biases1 = flatBiases.prefix(biasesCrossoverPoint)
			let biases2 = flatBiases.suffix(from: biasesCrossoverPoint)
			print("weights counts: \(weights1.count)/\(weights2.count), total: \(weights1.count + weights2.count)")
			print("biases counts: \(biases1.count)/\(biases2.count), total: \(biases1.count + biases2.count)")
			print()
		}
	}
		
	func testCrossover() throws {
				
		let genome1 = Genome(species: .herbivore, inputCount: 4, hiddenCounts: [4, 2], outputCount: 2)
		let genome2 = Genome(species: .herbivore, inputCount: 4, hiddenCounts: [4, 2], outputCount: 2)

		
		for genome in [genome1, genome2] {
			print()
			print("nodeCounts: \(genome.nodeCounts)")
			print("weight counts: \(genome.weightCounts)")
			print("bias counts: \(genome.biasCounts)")

			print()
			print("weights:")
			print(genome.weights)
			print()
			print("biases:")
			print(genome.biases)
			print()
		}
		
		// flatten
		let flatWeights1 = genome1.weights.flatMap { $0 }
		print("flatWeights1:\(flatWeights1)")
		let flatBiases1 = genome1.biases.flatMap { $0 }
		print("flatBiases1: \(flatBiases1)")
		print()
		let flatWeights2 = genome2.weights.flatMap { $0 }
		print("flatWeights2:\(flatWeights2)")
		let flatBiases2 = genome2.biases.flatMap { $0 }
		print("flatBiases2: \(flatBiases2)")
		print()

		// crossover

		let crossoverPoint = Float.random(in: 0...1)
		let weightsCrossoverPoint = Int(Float(flatWeights1.count) * crossoverPoint)
		let biasesCrossoverPoint = Int(Float(flatBiases1.count) * crossoverPoint)

		print("weightsCrossoverPoint: \(weightsCrossoverPoint)/\(flatWeights1.count)")
		print("biasesCrossoverPoint: \(biasesCrossoverPoint)/\(flatBiases1.count)")
		print()
		
		let weights1a = flatWeights1.prefix(weightsCrossoverPoint)
		let weights1b = flatWeights2.suffix(from: weightsCrossoverPoint)
		let weights2a = flatWeights2.prefix(weightsCrossoverPoint)
		let weights2b = flatWeights1.suffix(from: weightsCrossoverPoint)

		print("weights1 counts: \(weights1a.count)/\(weights1b.count), total: \(weights1a.count + weights1b.count)")
		print("weights2 counts: \(weights2a.count)/\(weights2b.count), total: \(weights2a.count + weights2b.count)")
		
		let biases1a = flatBiases1.prefix(biasesCrossoverPoint)
		let biases1b = flatBiases2.suffix(from: biasesCrossoverPoint)
		let biases2a = flatBiases2.prefix(biasesCrossoverPoint)
		let biases2b = flatBiases1.suffix(from: biasesCrossoverPoint)

		print("biases1 counts: \(biases1a.count)/\(biases1b.count), total: \(biases1a.count + biases1b.count)")
		print("biases2 counts: \(biases2a.count)/\(biases2b.count), total: \(biases2a.count + biases2b.count)")
		print()
		
		var newFlatWeights1 = weights1a + weights1b
		var newFlatBiases1 = biases1a + biases1b
		var newFlatWeights2 = weights2a + weights2b
		var newFlatBiases2 = biases2a + biases2b
		print("newFlatWeights1: \(newFlatWeights1)")
		print("newFlatBiases1: \(newFlatBiases1)")
		print("newFlatWeights2: \(newFlatWeights2)")
		print("newFlatBiases2: \(newFlatBiases2)")
		print()
		
		// reconstitute 1
		var newWeights1: [[Float]] =  []
		for layerCount in genome1.weightCounts {
			if layerCount > 0 {
				newWeights1.append(Array(newFlatWeights1.prefix(layerCount)))
				newFlatWeights1 = newFlatWeights1.suffix(newFlatWeights1.count - layerCount)
			}
			else {
				newWeights1.append([])
			}
		}
		print("newWeights1: \(newWeights1)")

		var newBiases1: [[Float]] =  []
		for layerCount in genome1.biasCounts {
			if layerCount > 0 {
				newBiases1.append(Array(newFlatBiases1.prefix(layerCount)))
				newFlatBiases1 = newFlatBiases1.suffix(newFlatBiases1.count - layerCount)
			}
			else {
				newBiases1.append([])
			}
		}
		print("newBiases1: \(newBiases1)")
		
		// reconstitute 2
		var newWeights2: [[Float]] =  []
		for layerCount in genome2.weightCounts {
			if layerCount > 0 {
				newWeights2.append(Array(newFlatWeights2.prefix(layerCount)))
				newFlatWeights2 = newFlatWeights2.suffix(newFlatWeights2.count - layerCount)
			}
			else {
				newWeights2.append([])
			}
		}
		print("newWeights2: \(newWeights2)")

		var newBiases2: [[Float]] =  []
		for layerCount in genome1.biasCounts {
			if layerCount > 0 {
				newBiases2.append(Array(newFlatBiases2.prefix(layerCount)))
				newFlatBiases2 = newFlatBiases2.suffix(newFlatBiases2.count - layerCount)
			}
			else {
				newBiases2.append([])
			}
		}
		print("newBiases2: \(newBiases2)")
		print()

	}
	
	func testMutationRate() throws {
		
		//for mutationRate: CGFloat in stride(from: 0, through: 1, by: 0.1) {
		let runCount = 50000
		
		print()
		for mutationRate: CGFloat in stride(from: 0, through: 1, by: 0.1) {
			
			var totalWeightsChances = 0
			var totalBiasesChances = 0
			var maxWeightChance = 0
			var minWeightChance = 1000
			var maxBiasChance = 0
			var minBiasChance = 1000

			
			for _ in 1...runCount {
				// mutationRate: 1...0 ==> 4...0 chances
				let weightsChances = Int.random(Int(2 + 3*mutationRate))
				// mutationRate: 1...0 ==> 1...0 chances
				let biasesChances = Int.oneChanceIn(12 - Int(2 + 6*mutationRate)) ? 1 : 0
				
				totalWeightsChances += weightsChances
				totalBiasesChances += biasesChances
				minWeightChance = min(minWeightChance, weightsChances)
				maxWeightChance = max(maxWeightChance, weightsChances)
				minBiasChance = min(minBiasChance, biasesChances)
				maxBiasChance = max(maxBiasChance, biasesChances)
				//print("mutationRate: \(mutationRate.formatted), weightsChances: \(weightsChances), biasesChances: \(biasesChances)")
			}
			
			let weightChancesAverage = CGFloat(totalWeightsChances) / CGFloat(runCount)
			let biasChancesAverage = CGFloat(totalBiasesChances) / CGFloat(runCount)
			print("mutationRate: \(mutationRate.formatted): weightChances: \(weightChancesAverage.formattedTo4Places), \(minWeightChance)–\(maxWeightChance), biasChances: \(biasChancesAverage.formattedTo4Places), \(minBiasChance)–\(maxBiasChance)")
			}
		
		print()
	}
	
	func testMutation() throws {
				
		var genome = Genome(species: .herbivore, inputCount: 5, hiddenCounts: [4, 3], outputCount: 2)

		let weightCounts = genome.weightCounts
		let biasCounts = genome.biasCounts
		
		var randomizedWeights: [[Float]] = []
		var randomizedBiases: [[Float]] = []

		for weightCount in 0..<weightCounts.count {
			var randomizedLayer: [Float] = []
			for _ in 0..<weightCounts[weightCount] {
				randomizedLayer.append(0)
			}
			randomizedWeights.append(randomizedLayer)
		}
		
		for biasCount in 0..<biasCounts.count {
			var randomizedLayer: [Float] = []
			for _ in 0..<biasCounts[biasCount] {
				randomizedLayer.append(0)
			}
			randomizedBiases.append(randomizedLayer)
		}
					
		// mutate
//		let randomWeightLayerIndex = Int.random(min: 1, max: weightCounts.count - 1)
//		let randomWeightIndex = Int.random(min: 0, max: randomizedWeights[randomWeightLayerIndex].count - 1)
//		randomizedWeights[randomWeightLayerIndex][randomWeightIndex] = 1
//
//		let randomBiasLayerIndex = Int.random(min: 1, max: biasCounts.count - 1)
//		let randomBiasIndex = Int.random(min: 0, max: randomizedBiases[randomBiasLayerIndex].count - 1)
//		randomizedBiases[randomBiasLayerIndex][randomBiasIndex] = 1

		print(randomizedWeights)
		print()
		print(randomizedBiases)
		
		genome.weights = randomizedWeights
		genome.biases = randomizedBiases
		
		for _ in 1...10 {
			genome.mutate(mutationRate: 1)
		}
		
		print(genome.jsonString)
	}

	func testBitMasks() throws {

		let player: UInt32 = 1
		let wall: UInt32 = 2

		let playerDetection: UInt32 = player | wall
		XCTAssertTrue(playerDetection == player | wall)
		XCTAssertTrue(player & player > 0)
		XCTAssertTrue(player & playerDetection > 0)
		XCTAssertFalse(player & wall > 0)
		XCTAssertTrue(wall & playerDetection > 0)
	}
		
	func testDispensary() throws {
		let minCount = 14
		let maxCount = 28
		let gameConfig = GameConfig(simulationMode: .predatorPrey, worldBlockCount: 10, algaeTarget: 10000, minimumBiotCount: minCount, maximumBiotCount: maxCount)
		let _ = GenomeDispensary(dispensaryType: .omnivore, gameConfig: gameConfig)
		let _ = GenomeDispensary(dispensaryType: .herbivore, gameConfig: gameConfig)
	}
	
//	func testAlterSaveFile() throws {
//		
//		if var saveState: SaveState = LocalFileManager.shared.loadDataFile("Save_almost", treatAsWarning: true) {
//			let gameConfig = GameConfig(saveState: saveState)
//			//let omnivores = gameConfig.omnivoreGenomes
//			let herbivores = gameConfig.herbivoreGenomes
//			var alteredGenomes: [Genome] = []
//			for var herbivore in herbivores {
//				herbivore.generation = 50
//				alteredGenomes.append(herbivore)
//			}
//
//			saveState.genomes = alteredGenomes
//			LocalFileManager.shared.saveStateToFile(saveState, filename: "Save_altered")
//		}
//	}
	
	func testTimer() {
		for age in 0..<200 {
			let value = Int.timerForAge(age, clockRate: 60)
			print("age: \(age), value: \(value.formattedTo2Places)")
		}
	}
	
	func testRunningValue() {
		let rv = RunningValue(memory: 10)
	
		for value in 1...10 {
			rv.addValue(Float(value))
			print("vals: \(rv.values.map({$0.formattedTo2Places})), avg: \(rv.average), last3: \(rv.averageOfMostRecent(memory: 3))")
		}
	}
	
	func testNoise() {
		
//		var angleIndex = 0
//		for angle in stride(from: 0, to: 2*π, by: π/16) {
//			print("\(angleIndex): \(angle.degrees.formattedTo2Places)")
//			angleIndex += 1
//		}
		
		let source = GKPerlinNoiseSource(
			frequency: 1, octaveCount: 4, persistence: 0.8, lacunarity: 2, seed: Int32(Int.random(10000)))
		let desiredSamples = Int32(32)
		let noise = GKNoise(source)
		let size = vector2(1.0, 1.0)
		let origin = vector2(0.0, 0.0)
		let sampleCount = vector2(desiredSamples, Int32(1))

		let noiseMap = GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)

		var values: [CGFloat] = []
		for i: Int32 in 0..<desiredSamples {
			let value = noiseMap.value(at: vector2(i, Int32(0)))
			values.append(CGFloat(value))
		}
		
		// values -1...1
		//values = values.map({ ($0 + 1)/2 })
		// values 0...1

		print(values)
		print(values.max() ?? 0)
		print(values.min() ?? 0)
	}
}
