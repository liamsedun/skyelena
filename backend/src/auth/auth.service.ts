import { Injectable, ConflictException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';
import { SignupDto } from './dto/signup.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async signup(dto: SignupDto) {
    const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (existing) {
      throw new ConflictException('Email already registered');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 12);

    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        password: hashedPassword,
        name: dto.name,
        businessName: dto.businessName,
        businessPhone: dto.businessPhone,
        settings: {
          create: {
            businessName: dto.businessName || '',
          },
        },
        subscription: {
          create: {
            tier: 'FREE',
            minutesLimit: 50,
          },
        },
      },
      select: {
        id: true,
        email: true,
        name: true,
        businessName: true,
        businessPhone: true,
        createdAt: true,
      },
    });

    const token = this.jwtService.sign({ sub: user.id, email: user.email });

    return { user, token };
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const passwordValid = await bcrypt.compare(dto.password, user.password);
    if (!passwordValid) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const token = this.jwtService.sign({ sub: user.id, email: user.email });

    const { password, ...userWithoutPassword } = user;
    return { user: userWithoutPassword, token };
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        businessName: true,
        businessPhone: true,
        stripeCustomerId: true,
        createdAt: true,
        subscription: true,
        settings: true,
      },
    });
    return user;
  }
}
