class Animal:
    def __init__(self, name):
        self.name = name

    def speak(self):
        pass

    def __str__(self):
        return self.name


class Dog(Animal):
    sound = 'Bark bark!'

    def __init__(self, name, breed):
        Animal.__init__(self, name)
        self.breed = breed

    def speak(self):
        return self.sound

    def __str__(self):
        return 'My dog is named ' + self.name + ', a ' + self.breed


if __name__ == '__main__':
    my_dog = Dog('Fido', 'Huskie')

    print(my_dog)

    print(my_dog.name, ', speak!', sep='')
    print()

    print(my_dog.name, my_dog.speak(), sep=': ')