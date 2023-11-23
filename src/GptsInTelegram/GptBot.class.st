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
GptBot >> config: aMessage [

	aMessage answer: self describeMe.
	aMessage chat assistant
		ifNotNil: [ :it | 
			aMessage answer:
				(self descriptionForAssistant: it highlightAsCurrent: false) ]
		ifNil: [ aMessage answer: '*Assistant*: not set' ].
	self playgroundUrl: aMessage.
]

{ #category : #commands }
GptBot >> deleteFile: aMessage [

	| fileId api availableFiles theFile |
	api := AssistantsAPI new.
	availableFiles := api files.
	fileId := (aMessage text
		           copyFrom: '/deleteFile' size + 1
		           to: aMessage text size) trimBoth.
	theFile := availableFiles
		           detect: [ :each | each id = fileId ]
		           ifNone: [ 
		           ^ aMessage answer:
			             'That is not the id of an existing file' ].

	[ AssistantsAPI new deleteFile: theFile ]
		on: Error
		do: [ 
			^ aMessage answer:
				  'Sorry; there was an error trying to delete the file' ].
	aMessage answer:
		'File has been deleted. Use \/files to get the list of available files'
]

{ #category : #commands }
GptBot >> describeMe [

	^ String streamContents: [ :strm | 
		  me firstname ifNotNil: [ :it | 
			  strm
				  nextPutAll: '*Name:* ';
				  nextPutAll: (self withScapedMarkdownCharacters: it);
				  lf ].
		  me username ifNotNil: [ :it | 
			  strm
				  nextPutAll: '*User name:* ';
				  nextPutAll: (self withScapedMarkdownCharacters: it);
				  lf ] ]
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

	| files |
	files := AssistantsAPI new files.
	files ifNil: [ 
		^ aMessage answer: 'Sorry; I am having issues taking to OpenAI API' ].
	files ifEmpty: [ ^ aMessage answer: 'There are no files ... send a message with a pdf file to upload it' ].
	files do: [ :file | 
		aMessage answer:
			(self withScapedMarkdownCharacters: file id , ' ' , file name) ]
]

{ #category : #hooks }
GptBot >> handleDocumentMessage: aMessage [

	| fileReference |
	fileReference := aMessage document fileName asFileReference.
	fileReference binaryWriteStream
		nextPutAll: (aMessage document readStreamWith: self) contents;
		close.
	aMessage answer:
		'I''ll try to upload a file so I can use it. It may take a while ...'.
	AssistantsAPI new uploadFile: fileReference fullName.
	fileReference delete.
	aMessage answer:
		'The file should now be available. Just to be sure, check it with \/files'
]

{ #category : #handling }
GptBot >> handleTextMessage: aMessage [

	|  mentionsMe text |
	text := aMessage text.
	mentionsMe := aMessage doesMention: me .
	mentionsMe ifTrue: [ text := text copyWithRegex: me matchesTranslatedUsing: [:each | ''] ].
	aMessage chat assistantsThread post: aMessage text by: aMessage from.   
	self sendBotIsTypingTo: aMessage chat. 
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
	
	aMessage answer: 'pong'
]

{ #category : #commands }
GptBot >> playgroundUrl: aMessage [

	aMessage answer:
		'[Open thread in playground]', '(' , aMessage chat assistantsThread playgroundUrl , ')'
]

{ #category : #commands }
GptBot >> restartGptThread: aMessage [

	| thread |
	thread := AssistantsAPI new newThread.
	thread ifNil: [ 
		^ aMessage answer:
			  'There was an issue trying to create a new thread.' ].

	aMessage chat assistantsThread: thread.
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

	aMessage chat assistant ifNotNil: [ :it | 
		it id = assistantId ifTrue: [ 
			aMessage answer:
				'That is the one you are currently using. Nothing to do but to remind you ... '.
			aMessage answer: (self
					 descriptionForAssistant: aMessage chat assistant
					 highlightAsCurrent: true).
			^ self ] ].


	theAssistant := AssistantsAPI new assistants
		                detect: [ :anAssistant | 
		                anAssistant id = assistantId ]
		                ifNone: [ 
		                ^ aMessage answer:
			                  'no assistant with id "' , assistantId , '"' ].

	aMessage chat assistant: theAssistant.

	aMessage answer: 'Assistant changed. Now using: '.
	aMessage answer:
		(self descriptionForAssistant: theAssistant highlightAsCurrent: true)
]

{ #category : #commands }
GptBot >> useFile: aMessage [

	| fileId file api |
	fileId := (aMessage text
		           copyFrom: '/useFile' size + 1
		           to: aMessage text size) trimBoth.
	api := AssistantsAPI new.
	file := api files
		        detect: [ :aFile | aFile id = fileId ]
		        ifNone: [ 
		        ^ aMessage answer: 'no file with id "' , fileId , '"' ].
	aMessage chat assistant fileIds: { fileId }.
	api postAssistant: aMessage chat assistant .
	aMessage answer: (self withScapedMarkdownCharacters:
			 'Ok, using file: ' , file id , ' - ' , file name)
]
