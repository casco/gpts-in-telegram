Class {
	#name : #GptBot,
	#superclass : #PollingTelegramBot,
	#category : #GptsInTelegram
}

{ #category : #hooks }
GptBot >> chatBuilderClass [

	^ GptChatBuilder
]

{ #category : #hooks }
GptBot >> handleTextMessage: aMessage [

	aMessage chat assistantsThread post: aMessage text by: aMessage from.
	(aMessage doesMention: me) ifFalse: [ ^ self ].
	aMessage answer: 'Let me think ... '.
	aMessage chat askTheAssistant
]

{ #category : #handling }
GptBot >> handleUnknownEvent: anUnknownUpdate [

	Transcript show: 'Unknown event'
]

{ #category : #testing }
GptBot >> hasElephantMemory [

	^ true
]
