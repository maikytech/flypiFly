//
//  GameScene.swift
//  flypiFly2
//
//  Created by Maiqui Cedeño on 5/1/16.
//  Copyright (c) 2016 maikytech. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate          //Se implementa el protocolo SKPhysicsContactDelegate, para el manejo de colisiones.
{
    
    var fly = SKSpriteNode()                                //La clase SKSpriteNode se utliza para configurar y mostrar un sprite en pantalla.
    var skyColor = SKColor()                                //Variable para colocar el color del cielo en el background.
    var floorTexture = SKTexture()                          //Variable que representa la textura del suelo.
    var landscapeTexture = SKTexture()                      //Variable que referencia al paisaje de fondo.
    var tuboDificultad = 380.0                              //Espacio entre los tubos para que pase la mosca, determina la dificultad.
    var tuboTexture1 = SKTexture(imageNamed:"Tubo1")        //Variable que referencia el tubo que mira hacia arriba.
    var tuboTexture2 = SKTexture(imageNamed:"Tubo2")        //Variable que referencia el tubo que mira hacia abajo.
    var moverRemover = SKAction()                           //Variable tipo SKAction para la dinamica de aparicion de los tubos.
    var gameOverLabel = SKLabelNode()                       //Variable que mostrara un label cada vez que el usuario pierda.
    var soloTubos = SKNode()                                //Variable donde van a estar solo los tubos.
    var dMovimiento = SKNode()                              //Variable general donde van a estar todos los nodos completos incluyendo soloTubos(hijo), para uso del reset.
    var puntuacionLabel = SKLabelNode()                     //Variable que mostrara un label con el puntaje.
    var puntuacion = NSInteger()                            //Llevara el conteo de la puntuacion.
    var reset = false                                       //Variable de Reset
    
    //Constantes de Tipos
    
    let tipoFly:UInt32 = 1                  //Tipos para el manejo de colisiones y puntuacion.
    let tipoMundo:UInt32 = 2
    let tipoTubo:UInt32 = 4
    let tipoPuntuacion:UInt32 = 8
    
    override func didMove(to _ view: SKView)                   //Similar al viewDidLoad, mostrara la aplicacion
    {
        self.physicsWorld.gravity = CGVectorMake(0.0, -3.0)         //Se modifica la gravedad del juego.
                                                                    //La propiedad physicsWorld crea un mundo fisico para el juego.
        self.physicsWorld.contactDelegate = self                    //Este delegado se activa cada que existe una colision.
        
        
        skyColor = SKColor(red: 114/255, green: 200/255, blue: 208/255, alpha: 1)
        self.backgroundColor = skyColor                                             //Colocamos a skyColor en el background.
        
        //Configuracion Label de Game Over
        
        gameOverLabel.setScale(4)                           //Tamaño de la letra.
        gameOverLabel.fontName = "Arial-Bold"
        gameOverLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        gameOverLabel.alpha = 0.0
        gameOverLabel.text = "Game Over"
        gameOverLabel.zPosition = 40
        self.addChild(gameOverLabel)                        //Se adiciona el label a la vista.
        
        //Configuracion Label puntuacion
        
        puntuacion = 0
        puntuacionLabel.setScale(2)
        puntuacionLabel.fontName = "Helvetica-Bold"
        puntuacionLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/1.5)
        puntuacionLabel.fontColor = UIColor.blackColor
        puntuacionLabel.zPosition = 50
        puntuacionLabel.text = "\(puntuacion)"              //Se adiciona al texto el valor de la variable puntuacion.
        self.addChild(puntuacionLabel)
        
        
        self.addChild(dMovimiento)                          //Se adiciona a la vista la variable dMovimiento.
        dMovimiento.addChild(soloTubos)                     //soloTubos se hace hijo de dMovimiento.
        
        
        // Ajuste de la mosca ////////////////////////////////////////////
        
        
        //Creamos una variable tipo SKTexture y le asignamos una imagen importada llamada "flyMini1", esta se comporta como una textura.
        let flyTexture = SKTexture(imageNamed: "flyMini1")          //Un objeto SKTexture es una imagen que puede ser aplicada a un SKSpriteNode.
        
        //filteringMode es una propiedad que es usada cuando el dibujado del sprite junto con la textura no se realiza en el tamaño nativo original de la textura.
        //SKTextureFilteringMode es una estructura que tiene diferentes modos de hacer el filtro.
        //Nearest dibuja cada pixel con el punto mas cercano a la textura, lo que le da el efecto de pixelado.
        flyTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let flyTexture2 = SKTexture(imageNamed: "flyMini2")
        flyTexture2.filteringMode = SKTextureFilteringMode.nearest
        
        let flyTexture3 = SKTexture(imageNamed: "flyMini3")
        flyTexture3.filteringMode = SKTextureFilteringMode.Nearest
        
        //La clase SKAction crea una accion.
        //El metodo de clase animateWithTextures crea una animacion a partir de una secuencia de texturas, sus parametros son un array con las texturas y una variable de tiempo en segundos.
        let animationFly = SKAction.animate(with: [flyTexture, flyTexture2, flyTexture3], timePerFrame: 0.1)
        
        let flyFlight = SKAction.repeatActionForever(animationFly)      //repeatActionForever repite una accion por siempre.
        
        fly = SKSpriteNode(texture: flyTexture)                                             //Se aplica la textura a la variable "fly".
        fly.anchorPoint = CGPoint(x: 0.5, y: 0.5)                                           //Se coloca el punto de anclado en toda la mitad del nodo.
        fly.position = CGPoint(x: self.frame.size.width/3, y: self.frame.size.height/2)     //Posisicion de "fly" a mitad de la pantalla.
        fly.run(flyFlight)                                                             //Corremos la animacion de la mosca.
        
        //Escalamos la imagen para volverla mas pequeña.
        //fly.xScale = 0.03
        //fly.yScale = 0.03
        
        //Gravedad
        
                                                                                //La propiedad physicsBody le agrega un cuerpo rigido a un nodo.
        fly.physicsBody = SKPhysicsBody(circleOfRadius: fly.size.height/2)      //La clase SKPhysicsBody es usada para agregar un simulacion fisica a un nodo.
        fly.physicsBody?.dynamic = true                                         //Para objetos que necesitan colisionar con otros y tener masa.
        
        //Colisiones Mosca
        
        fly.physicsBody?.categoryBitMask = tipoFly                      //La propiedad categoryBitMask es una mascara que define una categoria para el nodo.
        fly.physicsBody?.collisionBitMask = tipoMundo | tipoTubo        //La propiedad collisionBitMask es una mascara que define con que categoria se detectara una colision.
        fly.physicsBody?.contactTestBitMask = tipoTubo | tipoMundo      //Define con que categorias se genera una notificacion en caso de colision.
        

        // Ajuste del Fondo /////////////////////////////////////////////
        
        landscapeTexture = SKTexture(imageNamed: "bg")
        
        //Animacion del fondo
        
        let animacionFondo = SKAction.moveByX(-743, y: 0, duration: NSTimeInterval(8))     //Se mueve el fondo de su posicion original hacia la izquierda -743 pixeles en 800 ms
        let initFondo = SKAction.moveByX(743, y: 0, duration: 0)                             //Se devolvera a su posicion original en cero segundos.
        let loopFondo = SKAction.repeatActionForever(SKAction.sequence([animacionFondo, initFondo]))    //Se crea una secuencia con las dos acciones anteriores.
        
        for var i:CGFloat = 0; i < self.frame.width/(landscapeTexture.size().width) + 1; i++
        {
            let spriteLandscape = SKSpriteNode(texture: landscapeTexture)
            
            //Ajustamos el punto de anclaje al sprite del suelo a la esquina inferior izquierda.
            //anchorPoint coloca el punto de anclaje por defecto en (0.5, 0.5), es decir en la mitad del sprite, esa es la razon de la expresion "y: spriteFloor.size.height/2".
            spriteLandscape.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            spriteLandscape.position = CGPoint(x: i*spriteLandscape.size.width , y: 19)
            spriteLandscape.runAction(loopFondo)                                            //Agregamos la animacion del fondo.
            dMovimiento.addChild(spriteLandscape)                                           //Agregamos el fondo a dMovimiento.
            //self.addChild(spriteLandscape)
        }

        
        // Ajuste del Suelo /////////////////////////////////////////////

        floorTexture = SKTexture(imageNamed: "Suelo")               //Asignamos el sprite "Suelo" a la variable que representa la textura del suelo.
        
        //Animacion del suelo
        
        let animacionSuelo = SKAction.moveByX(-36, y: 0, duration: NSTimeInterval(0.4))     //Se mueve el suelo de su posicion original hacia la izquierda -36 pixeles en 400 ms
        let initSuelo = SKAction.moveByX(36, y: 0, duration: 0)                             //Se devolvera a su posicion original en cero segundos.
        let loopSuelo = SKAction.repeatActionForever(SKAction.sequence([animacionSuelo, initSuelo]))    //Se crea una secuencia con las dos acciones anteriores.
        
        
        
        for var i:CGFloat = 0; (i < self.frame.width/(floorTexture.size().width) + 2); i++      //Agregamos dos suelos mas para evitar el efecto de vacio en la animcion del suelo.
        {
            let spriteFloor = SKSpriteNode(texture: floorTexture)
            spriteFloor.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            spriteFloor.position = CGPoint(x: i*spriteFloor.size.width , y: 0)
            spriteFloor.runAction(loopSuelo)                                        //Agregamos la animacion del suelo.
            spriteFloor.zPosition = 20                                             //Hace que el suelo se vea mas adelante en 20 pixeles
            dMovimiento.addChild(spriteFloor)
            //self.addChild(spriteFloor)
        }
        
        // Suelo Falso
        
        let sueloFalso = SKNode()                                                                       //SKNode es la clase fundamental de SpriteKit.
        sueloFalso.position = CGPoint(x: 0, y: 0)                                                       //Se coloca el suelo falso en la posicion (0,0).
        sueloFalso.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.width, 96))       //Agregamos propiedad fisica rectangular.
        sueloFalso.physicsBody?.dynamic = false                                                         //No sera dinamico.
        sueloFalso.physicsBody?.categoryBitMask = tipoMundo                                             //Se asigna categoria para control de colisiones.
        self.addChild(sueloFalso)                                                                       //Se agrega suelo falso a la escena.
        
        
        //Tubos
        
        let crear = SKAction.runBlock(creaTubos)                                                    //La funcion de clase runBlock crea una accion que ejecuta un bloque de codigo.
        let retraso = SKAction.waitForDuration(NSTimeInterval(2.0))                                 //Pausa de dos segundos.
        let retrasoCompleto = SKAction.sequence([crear,retraso])                                    //Ejecuta la secuencia de la creacion de los tubos y el retraso.
        let retrasoEterno = SKAction.repeatActionForever(retrasoCompleto)                           //Ejecuta la accion retrasoCompleto por siempre.
        
        let distanciaAMover = CGFloat(self.frame.size.width * tuboTexture1.size().width)                                    //Distancia que se moveran los tubos.
        let moverTubos = SKAction.moveByX(-distanciaAMover, y: 0.0, duration: NSTimeInterval(0.01 * distanciaAMover))       //Mueve los tubos hacia la derecha.
        let removerTubos = SKAction.removeFromParent()                                                                      //Variable para remover los tubos de la pantalla.
        moverRemover = SKAction.sequence([moverTubos, removerTubos])                                                        //Secuencia que mueve y remueve los tubos.
        self.runAction(retrasoEterno)                                                                                       //Corremos la accion "retrasoEterno"
        
        fly.zPosition = 30                                                  //Hace que la mosca se vea mas adelante en 30 pixeles.
        dMovimiento.addChild(fly)
        //self.addChild(fly)                                                  //Asignamos fly a la vista.
    }
    
    func creaTubos()                        //Funcion que crea el tubo de arriba y el tubo de abajo como un par.
    {
        tuboTexture1 = SKTexture(imageNamed: "Tubo1")
        tuboTexture1.filteringMode = SKTextureFilteringMode.Nearest
        
        tuboTexture2 = SKTexture(imageNamed: "Tubo2")
        tuboTexture1.filteringMode = SKTextureFilteringMode.Nearest
        
        let parTubos = SKNode()
        parTubos.position = CGPointMake(self.frame.size.width + tuboTexture1.size().width, 0)
        parTubos.zPosition = 10
        
        let espacioEntreTubos = UInt32(self.frame.height/2)                 //Variable para que se muevan los tubos de arriba hacia abajo.
                                                                            //UInt32 es un entero sin signo, generalmente asociado a distancias.
        
        
        // Espacio entre tubos entre 70 y 380
        
        var y = espacioEntreTubos                   //Se genera un numero aleatorio de manera constante hasta que el numero generado se encuentre en el rango de 70 hasta 380 pixeles.
        repeat{
            y = arc4random() % espacioEntreTubos
        }while (y < 70 || y > 380)
        
        
        let tubo1 = SKSpriteNode(texture: tuboTexture1)
        tubo1.position = CGPointMake(0.0, CGFloat(y))                                   //Se posiciona el tubo en (0, y).
        tubo1.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(60, 600))         //CGSizeMake devuelve un tamaño con los valores de las dimensiones especificadas.
        tubo1.physicsBody?.dynamic = false
        tubo1.physicsBody?.categoryBitMask = tipoTubo
        tubo1.physicsBody?.contactTestBitMask = tipoFly                                 //Indicamos a tubo1 con que tipo de objeto puede chocar.
        parTubos.addChild(tubo1)                                                        //Hacemos a tubo1 hijo de parTubos
        
        let tubo2 = SKSpriteNode(texture: tuboTexture2)
        tubo2.position = CGPointMake(0.0, CGFloat(y) + CGFloat(tuboDificultad) + tubo1.size.height)
        tubo2.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(60, 600))
        tubo2.physicsBody?.dynamic = false
        tubo2.physicsBody?.categoryBitMask = tipoTubo
        tubo2.physicsBody?.contactTestBitMask = tipoFly
        parTubos.addChild(tubo2)                                                        //Hacemos a tubo2 hijo de parTubos
        
        let nodoContacto = SKNode()                                                                 //Variables que detecta cuando la mosca pasa entre tubos.
        nodoContacto.position = CGPointMake(tubo1.size.width/2, CGRectGetMidY(self.frame))
        nodoContacto.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(tubo1.size.width, self.frame.size.height))
        nodoContacto.physicsBody?.dynamic = false
        parTubos.addChild(nodoContacto)
        nodoContacto.physicsBody?.categoryBitMask = tipoPuntuacion
        nodoContacto.physicsBody?.contactTestBitMask = tipoFly
        
        parTubos.runAction(moverRemover)
        soloTubos.addChild(parTubos)
        //self.addChild(parTubos)
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact)                  //Metodo de instancia que se llama cuando dos cuerpos entran en contacto, tiene como parametro un objeto tipo SKPhysicsContact
    {
        if ((contact.bodyA.categoryBitMask & tipoPuntuacion) == tipoPuntuacion || (contact.bodyB.categoryBitMask & tipoPuntuacion) == tipoPuntuacion)
        {
            puntuacion += 1
            puntuacionLabel.text = "\(puntuacion)"
        }else{
                if(gameOverLabel.alpha == 0.0)
                {
                    gameOverLabel.alpha = 1.0
                }
            
                if dMovimiento.speed > 0                                   //Si dMovimiento (cualquier cosa en su interior, se esta moviendo), entonces se hace dMovimiento.speed = 0.
                {
                    dMovimiento.speed = 0
                }
            }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)    //Funcion que controla las acciones cuando se toca la pantalla.
    {
        if(gameOverLabel.alpha == 1.0)                  //Cuando el usuario pierde y vuelve a tocar la pantalla, el label desparece y se resetea el juego.
        {
            gameOverLabel.alpha = 0.0
            self.resetear()
        }
        
        if(dMovimiento.speed > 0)
        {
            fly.physicsBody?.velocity = CGVectorMake(0, 0)                      //La propiedad "velocity" es tipo vector en metros por segundo.
            fly.physicsBody?.applyImpulse(CGVectorMake(0, 48))                  //Aplica un impulso en el centro de gravedad del nodo, en Newton-seconds
        }
    }

    
    func resetear()
    {
        fly.position = CGPoint(x: self.frame.size.width/2.5, y: CGRectGetMidY(self.frame))  //CGRectGetMidY devuelve la coordenada Y que corresponde al centro del frame.
        fly.speed = 1.0
        fly.zRotation = 0.0
        soloTubos.removeAllChildren()                                                     //Borra todos los tubos de la pantalla.
        dMovimiento.speed = 1
        puntuacion = 0;
        puntuacionLabel.text = "\(puntuacion)"
    }

}
