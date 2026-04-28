import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToMany,
} from 'typeorm';
import { Cattle } from '../cattle/cattle.entity';
import { Expense } from '../expenses/expense.entity';

@Entity('owners')
export class Owner {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column({ nullable: true })
  phone: string;

  @Column({ nullable: true })
  address: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @OneToMany(() => Cattle, (cattle) => cattle.owner)
  cattle: Cattle[];

  @OneToMany(() => Expense, (expense) => expense.owner)
  expenses: Expense[];
}
