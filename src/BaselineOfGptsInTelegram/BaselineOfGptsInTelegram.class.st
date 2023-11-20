Class {
	#name : #BaselineOfGptsInTelegram,
	#superclass : #BaselineOf,
	#category : #BaselineOfGptsInTelegram
}

{ #category : #baselines }
BaselineOfGptsInTelegram >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		self openAiAssistants: spec.
		self telebots: spec.
		spec
			package: 'GptsInTelegram' with: [ spec requires: #( 'Telebots-Core' 'OpenAI-Assistants' ) ] ]
]

{ #category : #baselines }
BaselineOfGptsInTelegram >> openAiAssistants: spec [

	spec
		package: 'OpenAI-Assistants'
		with: [ spec repository: 'github://casco/openai-papi:main' ]
]

{ #category : #baselines }
BaselineOfGptsInTelegram >> telebots: spec [

	spec
		package: 'Telebots-Core'
		with: [ spec repository: 'github://casco/telebots' ]
]
