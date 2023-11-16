Class {
	#name : #GptChatBuilder,
	#superclass : #ChatBuilder,
	#category : #GptsInTelegram
}

{ #category : #'instance creation' }
GptChatBuilder >> build [

	super build.
	result assistantsThread: AssistantsAPI new newThread
]

{ #category : #'instance creation' }
GptChatBuilder >> newInstance [

	^ GptChat new
]
