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
	
	func testBiotParam() throws {
		let gens = [0, 10, 50, 75, 100, 200, 250]
		let params = [
			BiotParam(start: 10, end: 20),
			BiotParam(start: 30, end: 20),
			BiotParam(start: 0.1, end: 0.1),
			BiotParam(start: 0.0004, end: 0.0006)
		]
		
		for param in params {
			print(param.description)
			for gen in gens {
				print("gen: \(gen), value: \(param.valueForGeneration(gen))")
			}
			print()
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
		
		let genome = Genome(inputCount: 8, hiddenCounts: [4], outputCount: 2)
		
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
	
	func testMutation() throws {
				
		var genome = Genome(inputCount: 5, hiddenCounts: [4, 3], outputCount: 2)

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
			genome.mutate()
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
	

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//
//		guard let genome = GenomeFactory.shared.genomes.first else {
//			XCTFail()
//			return
//		}
//
//		var neuralNet: NeuralNet!
//
//		do {
//			var nodes: [Int] = []
//			nodes.append(genome.inputCount)
//			nodes.append(contentsOf: genome.hiddenCounts)
//			nodes.append(genome.outputCount)
//
//			let structure = try NeuralNet.Structure(nodes: nodes, hiddenActivation: .sigmoid, outputActivation: .sigmoid, batchSize: 1, learningRate: 0.1, momentum: 0.5)
//
//			neuralNet = try NeuralNet(structure: structure)
//			try neuralNet.setWeights(genome.weights)
//			try neuralNet.setBiases(genome.biases)
//
//		} catch let error {
//			XCTFail(error.localizedDescription)
//		}
//
//		let inputs: [[Float]] = [[0.01, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0.5]]
//
//        self.measure {
//			do {
//				for _ in 0..<10000 {
//					let _ = try neuralNet.infer(inputs)
//				}
//			} catch let error {
//				XCTFail(error.localizedDescription)
//			}
//        }
//    }
	
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
