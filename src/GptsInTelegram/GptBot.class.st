Class {
	#name : #GptBot,
	#superclass : #PollingTelegramBot,
	#category : #GptsInTelegram
}

{ #category : #commands }
GptBot >> assistants: aMessage [

	AssistantsAPI new assistants do: [ :each | 
		aMessage answer:
			(self descriptionForAssistant: each highlightAsCurrent: (aMessage chat assistant = each )) ]
]

{ #category : #commands }
GptBot >> catchUp: aMessage [

	| chatToCatchUp threadToCatchUpWith |
	chatToCatchUp := aMessage chat.
	threadToCatchUpWith := chatToCatchUp assistantsThread .
]

{ #category : #hooks }
GptBot >> chatBuilderClass [

	^ GptChatBuilder
]

{ #category : #commands }
GptBot >> descriptionForAssistant: anAssistant highlightAsCurrent: aBoolean [

	^ String streamContents: [ :strm | 
		  aBoolean ifTrue: [ 
			  strm nextPutAll: (self withScapedMarkdownCharacters: '(*) ') ].
		  strm
			  nextPutAll: '*Assistant name: *';
			  nextPutAll: (anAssistant name ifNil: [ 'Untitled assistant' ]);
			  lf.
		  strm
			  nextPutAll: '*Assistant id: *';
			  nextPutAll: (self withScapedMarkdownCharacters: anAssistant id);
			  lf.
		  strm nextPutAll: '*Files: *'.
		  anAssistant fileIds printOn: strm.
		  strm lf.
		  anAssistant instructions ifNotNil: [ 
			  strm
				  nextPutAll: '*Instructions: *';
				  nextPutAll:
					  (self withScapedMarkdownCharacters: anAssistant instructions);
				  lf ] ]
]

{ #category : #commands }
GptBot >> files: aMessage [

	(AssistantsAPI new files ) do: [ :file | 
		aMessage answer: file id, ' - ', file name ]
]

{ #category : #hooks }
GptBot >> handleTextMessage: aMessage [

	|  mentionsMe text |
	text := aMessage text.
	mentionsMe := aMessage doesMention: me .
	mentionsMe ifTrue: [ text := text copyWithRegex: me matchesTranslatedUsing: [:each | ''] ].
	aMessage chat assistantsThread post: aMessage text by: aMessage from.   
	aMessage 	chat askTheAssistantInResponseTo: aMessage. 
	
	

]

{ #category : #handling }
GptBot >> handleUnknownEvent: anUnknownUpdate [

	Transcript show: 'Unknown event'
]

{ #category : #testing }
GptBot >> hasElephantMemory [

	^ true
]

{ #category : #commands }
GptBot >> ping: aMessage [
	
	aMessage answer: 'asst_ABIHOVgSQk80slWeAF8YjPku'
]

{ #category : #commands }
GptBot >> playgroundUrl: aMessage [

	aMessage answer:
		'[' , aMessage chat assistantsThread playgroundUrl , ']', '(' , aMessage chat assistantsThread playgroundUrl , ')'
]

{ #category : #commands }
GptBot >> restartGptThread: aMessage [

	aMessage chat assistantsThread: AssistantsAPI new newThread.
	aMessage answer:
		'I hope you are sure about that ... done ... no way to undo it.'.
	self playgroundUrl: aMessage
]

{ #category : #commands }
GptBot >> useAssistant: aMessage [

	| assistantId theAssistant |
	assistantId := (aMessage text
		                copyFrom: '/useAssistant' size + 1
		                to: aMessage text size) trimBoth.

	assistantId = aMessage chat assistant id ifTrue: [ 
		aMessage answer:
			'That is the one you are currently using. Nothing to do but to remind you ... '.
		aMessage answer: (self
				 descriptionForAssistant: aMessage chat assistant
				 highlightAsCurrent: true).
		^ self ].


	theAssistant := AssistantsAPI new assistants
		                detect: [ :anAssistant | 
		                anAssistant id = assistantId ]
		                ifNone: [ 
		                ^ aMessage answer:
			                  'no assistant with id "' , assistantId , '"' ].

	aMessage chat assistant: theAssistant.

	aMessage answer: 'Assistant changed. Now using: '.
	aMessage answer: (self descriptionForAssistant: theAssistant highlightAsCurrent: true)
]

{ #category : #commands }
GptBot >> useFile: aMessage [

	| fileId file |
	fileId := (aMessage text
		           copyFrom: '/useFile' size + 1
		           to: aMessage text size) trimBoth.

	file := AssistantsAPI new files
		        detect: [ :aFile | aFile id = fileId ]
		        ifNone: [ 
		        ^ aMessage answer: 'no file with id "' , fileId , '"' ].
	aMessage answer: 'Ok, using file: ' , file id , ' - ' , file name
]
