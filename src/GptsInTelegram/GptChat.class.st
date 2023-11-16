Class {
	#name : #GptChat,
	#superclass : #TelegramChat,
	#instVars : [
		'assistantsThread',
		'assistant'
	],
	#category : #GptsInTelegram
}

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
