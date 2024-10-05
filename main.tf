# Configuración del proveedor de AWS
provider "aws" {
  region     = "us-east-2"
}

# Creación de la VPC
resource "aws_vpc" "cloud_vpc" {
  cidr_block = "30.0.0.0/16"  # Rango de IP para la VPC
  enable_dns_support = true    # Habilitar soporte DNS
  enable_dns_hostnames = true   # Habilitar nombres de host DNS

  tags = {
    Name = "cloud_vpc"         # Etiqueta para la VPC
  }
}

# Subredes públicas

# Primera subred pública
resource "aws_subnet" "publica-1" {
  vpc_id            = aws_vpc.cloud_vpc.id  # ID de la VPC donde se crea la subred
  cidr_block        = "30.0.1.0/24"           # Rango de IP para la subred pública 1
  availability_zone = "us-east-2a"            # Zona de disponibilidad
  map_public_ip_on_launch = true # Ensures instances get public IPs

  tags = {
    Name = "publica-1"  # Etiqueta para la subred pública 1
  }
}

# Segunda subred pública
resource "aws_subnet" "publica-2" {
  vpc_id            = aws_vpc.cloud_vpc.id  # ID de la VPC donde se crea la subred
  cidr_block        = "30.0.2.0/24"           # Rango de IP para la subred pública 2
  availability_zone = "us-east-2b"            # Zona de disponibilidad
  map_public_ip_on_launch = true # Ensures instances get public IPs

  tags = {
    Name = "publica-2"  # Etiqueta para la subred pública 2
  }
}

# Subredes privadas

# Primera subred privada
resource "aws_subnet" "private-1" {
  vpc_id            = aws_vpc.cloud_vpc.id  # ID de la VPC donde se crea la subred
  cidr_block        = "30.0.3.0/24"           # Rango de IP para la subred privada 1
  availability_zone = "us-east-2a"            # Zona de disponibilidad

  tags = {
    Name = "private-1" # Etiqueta para la subred privada 1
  }
}

# Segunda subred privada
resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.cloud_vpc.id  # ID de la VPC donde se crea la subred
  cidr_block        = "30.0.4.0/24"           # Rango de IP para la subred privada 2
  availability_zone = "us-east-2b"            # Zona de disponibilidad

  tags = {
    Name = "private-2" # Etiqueta para la subred privada 2
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.cloud_vpc.id  # ID de la VPC a la que se asocia el gateway

  tags = {
    Name = "aws_gateway_internet"    # Etiqueta para el Internet Gateway
  }
}

# Tabla de enrutamiento para subredes públicas
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.cloud_vpc.id  # ID de la VPC a la que pertenece la tabla de enrutamiento

  route {
    cidr_block = "0.0.0.0/0"        # Ruta para todo el tráfico saliente
    gateway_id = aws_internet_gateway.igw.id  # ID del Internet Gateway
  }

  tags = {
    Name = "public_table"    # Etiqueta para la tabla de enrutamiento pública
  }
}

# Asociación de la tabla de enrutamiento a la subred pública 1
resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.publica-1.id  # ID de la subred pública 1
  route_table_id = aws_route_table.public_rt.id# ID de la tabla de enrutamiento pública
}


# Asociación de la tabla de enrutamiento a la subred pública 2
resource "aws_route_table_association" "public-association-2" {
  subnet_id      = aws_subnet.publica-2.id  # ID de la subred pública 2
  route_table_id = aws_route_table.public_rt.id    # ID de la tabla de enrutamiento pública
}


# Security Group (Allow all outgoing traffic for instances)
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.cloud_vpc.id

  ingress{
    from_port   = 22
    to_port     = 22
    protocol    = "tcp" # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"] 
  }
   ingress{
    from_port   = 80
    to_port     = 80
    protocol    = "tcp" # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance_security_group"
  }
}

resource "aws_instance" "ec2_public_1" {
  ami                     = "ami-09da212cf18033880"
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.publica-1.id
  key_name                = "cloud2"
  vpc_security_group_ids  = [aws_security_group.instance_sg.id]
  user_data = var.ec2_command
  associate_public_ip_address = true
    tags = {
      Name = "EC2_Public_1"
    }
}

resource "aws_instance" "ec2_public_2" {
  ami                     = "ami-09da212cf18033880"
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.publica-2.id
  key_name                = "cloud2"
  user_data = var.ec2_command
  associate_public_ip_address = true
  
  vpc_security_group_ids  = [aws_security_group.instance_sg.id]

    tags = {
      Name = "EC2_Public_2"
    }
}
