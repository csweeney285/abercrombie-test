A&F Test is written in Obj C, since it is my more comfortable language. I opted not to use auto layout since there are an unknown number of cards being added to the scroll view and it messed with my content resize method.

I considered creating a card view object with a xib file however when it became apparent that this more difficult than adding the views programmatically in the scrollview and unnecessary, I opted not to.

For the button presses. I tag every button with a unique number and I add the button’s url to a mutable array at that index. Then when the button is pressed, the sender’s tag is used to access the correct url in the array. Then the web view is pushed in a popover view.

I did my best to match the aesthetics with color and font. Obviously if this were for a real assignment I would require the font names and the rgb values for all the colors.