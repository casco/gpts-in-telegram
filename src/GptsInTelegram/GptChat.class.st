Class {
	#name : #GptChat,
	#superclass : #TelegramChat,
	#instVars : [
		'assistantsThread',
		'assistant'
	],
	#category : #GptsInTelegram
}

{ #category : #running }
GptChat >> askTheAssistant [

	assistant isNil | assistantsThread isNil ifTrue: [ self ].
	assistantsThread startRunFor: assistant
]

{ #category : #accessing }
GptChat >> assistant [

	^ assistant
]

{ #category : #accessing }
GptChat >> assistant: anObject [

	assistant := anObject
]

{ #category : #accessing }
GptChat >> assistantsThread [

	^ assistantsThread
]

{ #category : #accessing }
GptChat >> assistantsThread: anObject [

	assistantsThread := anObject
]
