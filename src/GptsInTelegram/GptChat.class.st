Class {
	#name : #GptChat,
	#superclass : #TelegramChat,
	#instVars : [
		'assistantsThread',
		'assistant',
		'runMonitor'
	],
	#category : #GptsInTelegram
}

{ #category : #running }
GptChat >> askTheAssistantInResponseTo: aMessage [

	runMonitor ifNotNil: [ 
		^ aMessage answer: 'Sorry, I can only work on one thing at a time' ].
	assistant isNil | assistantsThread isNil ifTrue: [ 
		^ aMessage answer:
			  'I seams I am not properly configure to act as GPT' ].
	runMonitor := (assistantsThread startRunFor: assistant)
		              monitorEvery: 1 second
		              onCompletedDo: [ :run | 
			              self theAssistantAnswered: run messages to: aMessage.
			              runMonitor := nil ]
		              onCanceledFailerOrExpiredDo: [ :run | 
			              aMessage answer:
				              'Sorry, something failed while I was trying to be a GPT'.
			              runMonitor := nil ]
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

{ #category : #running }
GptChat >> theAssistantAnswered: messages to: aMessage [

	messages do: [ :msg | aMessage answer: msg text ]
]
